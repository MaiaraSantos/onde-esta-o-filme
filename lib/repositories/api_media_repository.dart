import '../models/media_item.dart';
import '../services/tmdb_api_service.dart';
import '../services/watchmode_api_service.dart';
import 'media_repository.dart';
import '../config/app_config.dart';

class ApiMediaRepository implements MediaRepository {
  final TmdbApiService _tmdbService;
  final WatchmodeApiService _watchmodeService;

  final Map<String, int> _genreNameToId = {};
  final Map<int, String> _genreIdToName = {};

  ApiMediaRepository(this._tmdbService, this._watchmodeService);

  Future<void> _ensureGenresLoaded() async {
    if (_genreNameToId.isEmpty) {
      await getAvailableGenres();
    }
  }

  Future<List<MediaItem>> _enrichWithDuration(List<MediaItem> items) async {
    final enriched = await Future.wait(items.map((item) async {
      try {
        final typeStr = item.type == MediaType.tvShow ? 'tv' : 'movie';
        final details = await _tmdbService.getDetails(item.id, typeStr);
        return item.copyWith(
          duration: details['runtime'] != null ? '${details['runtime']} min' : null,
          seasonsCount: details['number_of_seasons'] as int?,
        );
      } catch (_) {
        return item;
      }
    }));
    return enriched;
  }

  @override
  Future<List<MediaItem>> searchMedia({
    String? query,
    List<String>? genres,
    String? streamingId,
    MediaType? type,
    String? sortBy,
  }) async {
    await _ensureGenresLoaded();

    if (query != null && query.isNotEmpty) {
      // 1. Busca por texto
      final results = await _tmdbService.search(query);
      var items = _mapTmdbResults(results);

      // Filtragem local
      if (type != null) {
        items = items.where((item) => item.type == type).toList();
      }
      if (genres != null && genres.isNotEmpty) {
        items = items.where((item) => genres.every((g) => item.genres.contains(g))).toList();
      }
      
      // Ordenação local
      if (sortBy != null) {
        items = _sortItemsLocally(items, sortBy);
      }

      return await _enrichWithDuration(items);
    }
    
    // 2. Discover (Sem Busca por texto)
    final params = <String, String>{};
    
    // Gêneros
    if (genres != null && genres.isNotEmpty) {
      final genreIds = genres.map((g) => _genreNameToId[g]).where((id) => id != null).join(',');
      if (genreIds.isNotEmpty) {
        params['with_genres'] = genreIds;
      }
    }
    
    // Streaming (Ignorar 'stremio' do TMDB)
    if (streamingId != null && streamingId.isNotEmpty && streamingId != 'stremio') {
      params['with_watch_providers'] = streamingId;
      params['watch_region'] = 'BR';
    }
    
    // Sort
    if (sortBy != null) {
      switch (sortBy) {
        case 'popularity':
          params['sort_by'] = 'popularity.desc';
          break;
        case 'rating':
          params['sort_by'] = 'vote_average.desc';
          params['vote_count.gte'] = '100';
          break;
        case 'date':
          params['sort_by'] = 'primary_release_date.desc';
          break;
        case 'alphabetical':
          params['sort_by'] = type == MediaType.tvShow ? 'name.asc' : 'title.asc';
          break;
      }
    }

    if (type == null) {
      final movieResults = await _tmdbService.discover(type: 'movie', params: params);
      final tvResults = await _tmdbService.discover(type: 'tv', params: params);
      
      var items = _mapTmdbResults(movieResults, defaultType: MediaType.movie)
        ..addAll(_mapTmdbResults(tvResults, defaultType: MediaType.tvShow));
        
      // Ordena localmente os resultados combinados
      items = _sortItemsLocally(items, sortBy ?? 'popularity');
      return await _enrichWithDuration(items);
    } else {
      final typeStr = type == MediaType.tvShow ? 'tv' : 'movie';
      final results = await _tmdbService.discover(type: typeStr, params: params);
      final items = _mapTmdbResults(results, defaultType: type);
      return await _enrichWithDuration(items);
    }
  }

  List<MediaItem> _sortItemsLocally(List<MediaItem> items, String sortBy) {
    final list = List<MediaItem>.from(items);
    switch (sortBy) {
      case 'popularity':
        list.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      case 'rating':
        list.sort((a, b) => b.displayRating.compareTo(a.displayRating));
        break;
      case 'date':
        list.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'alphabetical':
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  @override
  Future<MediaItem?> getMediaDetails(String id) async {
    try {
      // Como não sabemos se é filme ou série apenas pelo ID no método genérico,
      // podemos tentar filme primeiro, ou assumir que o ID tem um prefixo.
      // Porém, no nosso modelo, salvamos o type na lista.
      // O ideal é passar o type para o getMediaDetails, mas como a interface 
      // tem apenas (String id), vamos buscar como filme. Se falhar, busca como série.
      Map<String, dynamic>? data;
      MediaType type = MediaType.movie;
      
      try {
        data = await _tmdbService.getDetails(id, 'movie');
      } catch (_) {
        data = await _tmdbService.getDetails(id, 'tv');
        type = MediaType.tvShow;
      }

      if (data == null || data['id'] == null) return null;

      final item = _mapTmdbItem(data, type);

      // Buscar streamings no Watchmode
      final streamings = await _watchmodeService.getStreamingSources(id, type);
      
      // Criar lista de plataformas únicas (Watchmode pode retornar múltiplos links para a mesma plataforma)
      final uniqueStreamings = <String, StreamingPlatform>{};
      for (var s in streamings) {
        uniqueStreamings[s.id] = s;
      }

      // Injetar Stremio como opção de streaming
      String? imdbId;
      if (data['imdb_id'] != null && data['imdb_id'].toString().isNotEmpty) {
        imdbId = data['imdb_id'];
      } else if (data['external_ids'] != null && data['external_ids']['imdb_id'] != null && data['external_ids']['imdb_id'].toString().isNotEmpty) {
        imdbId = data['external_ids']['imdb_id'];
      }

      if (imdbId != null) {
        final stremioUrl = type == MediaType.movie 
            ? 'stremio:///detail/movie/$imdbId/$imdbId'
            : 'stremio:///detail/series/$imdbId/$imdbId:1:1';
            
        uniqueStreamings['stremio'] = StreamingPlatform(
          id: 'stremio',
          name: 'Stremio',
          logoUrl: 'https://www.stremio.com/website/stremio-logo-small.png',
          url: stremioUrl,
        );
      }

      return item.copyWith(streamingPlatforms: uniqueStreamings.values.toList());
    } catch (e) {
      print('Erro ao buscar detalhes do media: $e');
      return null;
    }
  }

  @override
  Future<List<MediaItem>> getPopularMedia({MediaType? type}) async {
    try {
      final typeStr = type == MediaType.tvShow ? 'tv' : 'movie';
      final results = await _tmdbService.getPopular(type: typeStr);
      final items = _mapTmdbResults(results, defaultType: type ?? MediaType.movie);
      return await _enrichWithDuration(items);
    } catch (e) {
      print('Erro ao buscar populares: $e');
      return [];
    }
  }

  @override
  Future<List<StreamingPlatform>> getAvailableStreamings() async {
    // Lista mockada de plataformas comuns para filtros, pois a API do Watchmode
    // para listar todos os streamings geralmente é muito grande.
    return const [
      StreamingPlatform(id: '8', name: 'Netflix'),
      StreamingPlatform(id: '119', name: 'Amazon Prime Video'),
      StreamingPlatform(id: '337', name: 'Disney+'),
      StreamingPlatform(id: '384', name: 'Max'),
      StreamingPlatform(
        id: 'stremio', 
        name: 'Stremio',
        logoUrl: 'https://www.stremio.com/website/stremio-logo-small.png',
      ),
    ];
  }

  @override
  Future<List<String>> getAvailableGenres() async {
    try {
      final movies = await _tmdbService.getGenres('movie');
      final tv = await _tmdbService.getGenres('tv');
      
      final genres = <String>{};
      for (var g in movies) {
        final name = g['name']?.toString() ?? '';
        final id = g['id'] as int?;
        if (name.isNotEmpty && id != null) {
          genres.add(name);
          _genreNameToId[name] = id;
          _genreIdToName[id] = name;
        }
      }
      for (var g in tv) {
        final name = g['name']?.toString() ?? '';
        final id = g['id'] as int?;
        if (name.isNotEmpty && id != null) {
          genres.add(name);
          _genreNameToId[name] = id;
          _genreIdToName[id] = name;
        }
      }
      return genres.where((g) => g.isNotEmpty).toList();
    } catch (e) {
      print('Erro ao buscar gêneros: $e');
      return [];
    }
  }

  // --- Funções Auxiliares ---

  List<MediaItem> _mapTmdbResults(List<dynamic> results, {MediaType? defaultType}) {
    return results
        .where((item) => item['media_type'] != 'person') // Filtra pessoas
        .map((item) {
          final typeStr = item['media_type'];
          final type = typeStr == 'tv'
              ? MediaType.tvShow
              : (typeStr == 'movie' ? MediaType.movie : (defaultType ?? MediaType.movie));
          return _mapTmdbItem(item, type);
        })
        .toList();
  }

  MediaItem _mapTmdbItem(Map<String, dynamic> item, MediaType type) {
    List<String> mappedGenres = [];
    if (item['genre_ids'] != null) {
      for (var id in item['genre_ids']) {
        if (_genreIdToName.containsKey(id)) {
          mappedGenres.add(_genreIdToName[id]!);
        }
      }
    } else if (item['genres'] != null) {
      for (var g in item['genres']) {
        mappedGenres.add(g['name']?.toString() ?? '');
      }
    }

    return MediaItem(
      id: item['id']?.toString() ?? '',
      title: (item['title'] ?? item['name'])?.toString() ?? '',
      year: _extractYear(item['release_date'] ?? item['first_air_date']),
      type: type,
      overview: item['overview']?.toString() ?? '',
      posterPath: item['poster_path'] != null ? '${AppConfig.tmdbImageBaseUrl}/w500${item['poster_path']}' : null,
      backdropPath: item['backdrop_path'] != null ? '${AppConfig.tmdbImageBaseUrl}/original${item['backdrop_path']}' : null,
      genres: mappedGenres,
      ratingTmdb: (item['vote_average'] as num?)?.toDouble() ?? 0.0,
      popularity: (item['popularity'] as num?)?.toDouble() ?? 0.0,
      streamingPlatforms: [], // Carregado apenas na tela de detalhes para economizar requisições
      seasonsCount: item['number_of_seasons'] as int?,
      duration: item['runtime'] != null ? '${item['runtime']} min' : null,
    );
  }

  int _extractYear(String? date) {
    if (date == null || date.length < 4) return 0;
    return int.tryParse(date.substring(0, 4)) ?? 0;
  }
}
