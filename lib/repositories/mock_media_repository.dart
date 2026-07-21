import '../models/media_item.dart';
import 'media_repository.dart';

class MockMediaRepository implements MediaRepository {
  // Lista estática de plataformas de streaming mockadas (Foco em Brasil)
  static const List<StreamingPlatform> _platforms = [
    StreamingPlatform(
      id: 'netflix',
      name: 'Netflix',
      logoUrl: 'https://images.ctfassets.net/4cd45et68cgf/Rx83JoRDMazg411NMD4Z3/464da65d1e94cf6744fa558cc66014e7/Netflix-Symbol.png',
      url: 'https://www.netflix.com',
    ),
    StreamingPlatform(
      id: 'prime_video',
      name: 'Prime Video',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Amazon_Prime_Video_logo.svg/512px-Amazon_Prime_Video_logo.svg.png',
      url: 'https://www.primevideo.com',
    ),
    StreamingPlatform(
      id: 'disney_plus',
      name: 'Disney+',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Disney%2B_logo.svg/512px-Disney%2B_logo.svg.png',
      url: 'https://www.disneyplus.com',
    ),
    StreamingPlatform(
      id: 'max',
      name: 'Max',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Max_logo.svg/512px-Max_logo.svg.png',
      url: 'https://www.max.com',
    ),
    StreamingPlatform(
      id: 'apple_tv',
      name: 'Apple TV+',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Apple_TV_Plus_Logo.svg/512px-Apple_TV_Plus_Logo.svg.png',
      url: 'https://tv.apple.com',
    ),
    StreamingPlatform(
      id: 'globoplay',
      name: 'Globoplay',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Globoplay_logo.svg/512px-Globoplay_logo.svg.png',
      url: 'https://globoplay.globo.com',
    ),
    StreamingPlatform(
      id: 'stremio', 
      name: 'Stremio',
      logoUrl: 'https://www.stremio.com/website/stremio-logo-small.png',
    ),
  ];

  // Lista estática de itens de mídia mockados
  static final List<MediaItem> _items = [
    MediaItem(
      id: '1',
      title: 'Interestelar',
      year: 2014,
      type: MediaType.movie,
      overview: 'As reservas naturais da Terra estão se esgotando e um grupo de astronautas recebe a missão de verificar possíveis planetas para receberem a população mundial, possibilitando a continuação da espécie humana.',
      posterPath: 'https://image.tmdb.org/t/p/w500/gEU2QvHOm5vqRdB2jIS7n3d12c1.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/xJHokZbljvCY55FCr6Nbrv68JuA.jpg',
      genres: ['Ficção Científica', 'Drama', 'Aventura'],
      duration: '2h 49min',
      ratingImdb: 8.7,
      ratingRottenTomatoes: 73.0,
      ratingTmdb: 8.4,
      streamingPlatforms: [_platforms[1], _platforms[3]], // Prime Video, Max
      popularity: 98.5,
    ),
    MediaItem(
      id: '2',
      title: 'A Origem',
      year: 2010,
      type: MediaType.movie,
      overview: 'Dom Cobb é um ladrão profissional que rouba segredos do subconsciente durante o estado de sono. Impedido de retornar para sua família, ele recebe uma oportunidade de redenção se conseguir implantar uma ideia na mente de um herdeiro de um império econômico.',
      posterPath: 'https://image.tmdb.org/t/p/w500/9gk7adHYeHCwb9m28EWCqekCDHg.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/8Zg0iBS312UPg6K31ItaViiB1Z5.jpg',
      genres: ['Ficção Científica', 'Ação', 'Suspense'],
      duration: '2h 28min',
      ratingImdb: 8.8,
      ratingRottenTomatoes: 87.0,
      ratingTmdb: 8.4,
      streamingPlatforms: [_platforms[1], _platforms[3]], // Prime Video, Max
      popularity: 92.4,
    ),
    MediaItem(
      id: '3',
      title: 'Breaking Bad',
      year: 2008,
      type: MediaType.tvShow,
      overview: 'Walter White, um professor de química do ensino médio diagnosticado com câncer de pulmão terminal, junta-se ao seu ex-aluno Jesse Pinkman para fabricar e vender metanfetamina para garantir o futuro financeiro de sua família.',
      posterPath: 'https://image.tmdb.org/t/p/w500/ztkUQv63U71926DU4zrgcrn6C65.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/tsRy66Vmby7nJ6JZ5JmOLt8nIqd.jpg',
      genres: ['Drama', 'Crime', 'Suspense'],
      seasonsCount: 5,
      ratingImdb: 9.5,
      ratingRottenTomatoes: 96.0,
      ratingTmdb: 8.9,
      streamingPlatforms: [_platforms[0]], // Netflix
      popularity: 99.1,
    ),
    MediaItem(
      id: '4',
      title: 'Stranger Things',
      year: 2016,
      type: MediaType.tvShow,
      overview: 'Quando um garoto desaparece, uma pequena cidade descobre um mistério envolvendo experimentos secretos, forças sobrenaturais aterrorizantes e uma estranha garotinha.',
      posterPath: 'https://image.tmdb.org/t/p/w500/x2LSRm2RMAv2ezCbJE762EVt66m.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/56v2DnL56Yor3vUOh1A36upzZ29.jpg',
      genres: ['Drama', 'Ficção Científica', 'Fantasia', 'Suspense'],
      seasonsCount: 4,
      ratingImdb: 8.7,
      ratingRottenTomatoes: 92.0,
      ratingTmdb: 8.6,
      streamingPlatforms: [_platforms[0]], // Netflix
      popularity: 95.8,
    ),
    MediaItem(
      id: '5',
      title: 'Batman: O Cavaleiro das Trevas',
      year: 2008,
      type: MediaType.movie,
      overview: 'Com a ajuda do tenente Jim Gordon e do promotor público Harvey Dent, Batman mantém a ordem em Gotham City. Mas um jovem e anárquico criminoso conhecido como Coringa surge para instaurar o caos na cidade.',
      posterPath: 'https://image.tmdb.org/t/p/w500/qJ2tWwGbZ2HFgH2g544iTT5htWt.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/nMKdUUepdz8gW50k7FEx20ihUeJ.jpg',
      genres: ['Ação', 'Drama', 'Crime', 'Ficção Científica'],
      duration: '2h 32min',
      ratingImdb: 9.0,
      ratingRottenTomatoes: 94.0,
      ratingTmdb: 8.5,
      streamingPlatforms: [_platforms[3]], // Max
      popularity: 96.0,
    ),
    MediaItem(
      id: '6',
      title: 'Matrix',
      year: 1999,
      type: MediaType.movie,
      overview: 'Um jovem programador de computador é atraído para uma rebelião misteriosa contra as máquinas que dominam o mundo, descobrindo que a realidade em que vive é uma simulação artificial.',
      posterPath: 'https://image.tmdb.org/t/p/w500/f89U3wLpqHYCYm7O98bbwfENrD5.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/lh50zRha4v4agj3uWLyeo2hDx0W.jpg',
      genres: ['Ficção Científica', 'Ação'],
      duration: '2h 16min',
      ratingImdb: 8.7,
      ratingRottenTomatoes: 83.0,
      ratingTmdb: 8.2,
      streamingPlatforms: [_platforms[1], _platforms[3]], // Prime Video, Max
      popularity: 88.0,
    ),
    MediaItem(
      id: '7',
      title: 'Succession',
      year: 2018,
      type: MediaType.tvShow,
      overview: 'Acompanhe a saga da família Roy, proprietária de um dos maiores impérios de mídia e entretenimento do mundo, enquanto os filhos disputam o controle da empresa diante da iminente aposentadoria do patriarca.',
      posterPath: 'https://image.tmdb.org/t/p/w500/74v7G2vY6WdNDBvSwsPqJ99eC1W.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/eYZv6UG6Wh4rrw7fyF7A7147n60.jpg',
      genres: ['Drama'],
      seasonsCount: 4,
      ratingImdb: 8.9,
      ratingRottenTomatoes: 94.0,
      ratingTmdb: 8.3,
      streamingPlatforms: [_platforms[3]], // Max
      popularity: 89.2,
    ),
    MediaItem(
      id: '8',
      title: 'The Last of Us',
      year: 2023,
      type: MediaType.tvShow,
      overview: 'Vinte anos após a destruição da civilização moderna por uma infecção fúngica, Joel, um sobrevivente experiente, é contratado para contrabandear Ellie, uma garota de 14 anos, para fora de uma zona de quarentena opressiva.',
      posterPath: 'https://image.tmdb.org/t/p/w500/uKVQ6g42of953sTz45Ue3B1N4N7.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/n5A7brj92ArROWNu5tcD76J1GPE.jpg',
      genres: ['Drama', 'Ação', 'Ficção Científica', 'Suspense'],
      seasonsCount: 1,
      ratingImdb: 8.8,
      ratingRottenTomatoes: 96.0,
      ratingTmdb: 8.6,
      streamingPlatforms: [_platforms[3]], // Max
      popularity: 97.2,
    ),
    MediaItem(
      id: '9',
      title: 'Ruptura',
      year: 2022,
      type: MediaType.tvShow,
      overview: 'Mark lidera uma equipe de funcionários de escritório cujas memórias foram divididas cirurgicamente entre a vida profissional e a pessoal. Quando um colega misterioso aparece fora do trabalho, começa uma jornada para descobrir a verdade sobre suas funções.',
      posterPath: 'https://image.tmdb.org/t/p/w500/abOZ56gA6uXlJ5G3HhM4g244xXp.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/9355L456X4j62rFm831S1p3C9B8.jpg',
      genres: ['Ficção Científica', 'Suspense', 'Drama'],
      seasonsCount: 1,
      ratingImdb: 8.7,
      ratingRottenTomatoes: 97.0,
      ratingTmdb: 8.4,
      streamingPlatforms: [_platforms[4]], // Apple TV
      popularity: 91.1,
    ),
    MediaItem(
      id: '10',
      title: 'Parasita',
      year: 2019,
      type: MediaType.movie,
      overview: 'Toda a família de Ki-taek está desempregada, vivendo num porão sujo. Por obra do acaso, o filho adolescente começa a dar aulas de inglês para a filha de uma família rica. Aos poucos, a família desempregada elabora um plano para se infiltrar na vida dos burgueses.',
      posterPath: 'https://image.tmdb.org/t/p/w500/7kHg135Xv0t2Zlcn5nZ5wHGk86c.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/z2o4621t9olS3q556557YV17m5m.jpg',
      genres: ['Drama', 'Suspense', 'Comédia'],
      duration: '2h 12min',
      ratingImdb: 8.5,
      ratingRottenTomatoes: 99.0,
      ratingTmdb: 8.5,
      streamingPlatforms: [_platforms[3], _platforms[5]], // Max, Globoplay
      popularity: 90.0,
    ),
    MediaItem(
      id: '11',
      title: 'Whiplash: Em Busca da Perfeição',
      year: 2014,
      type: MediaType.movie,
      overview: 'Andrew é um jovem baterista de jazz que sonha em ser o melhor de sua geração. Ele entra no conservatório de Shaffer e atrai a atenção de Terence Fletcher, um instrutor conhecido por seus métodos cruéis de ensino.',
      posterPath: 'https://image.tmdb.org/t/p/w500/29M5q5K87V20dD2B7V2yS3Hk0uP.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/6422mUskV6Gf722S45H3D8qfU4A.jpg',
      genres: ['Drama', 'Música'],
      duration: '1h 46min',
      ratingImdb: 8.5,
      ratingRottenTomatoes: 94.0,
      ratingTmdb: 8.4,
      streamingPlatforms: [_platforms[0], _platforms[1]], // Netflix, Prime Video
      popularity: 87.5,
    ),
    MediaItem(
      id: '12',
      title: 'O Menino e a Garça',
      year: 2023,
      type: MediaType.movie,
      overview: 'Durante a Segunda Guerra Mundial, o jovem Mahito se muda para a propriedade de sua família no campo após a trágica morte de sua mãe. Lá, ele encontra uma garça cinzenta falante que o leva a um mundo mágico e oculto.',
      posterPath: 'https://image.tmdb.org/t/p/w500/fec8y33bKk50H9yC42yXoE2R0uN.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/j612bKk50H9yC42yXoE2R0uN.jpg',
      genres: ['Animação', 'Fantasia', 'Aventura', 'Drama'],
      duration: '2h 4min',
      ratingImdb: 7.5,
      ratingRottenTomatoes: 97.0,
      ratingTmdb: 7.4,
      streamingPlatforms: [_platforms[0]], // Netflix
      popularity: 86.4,
    ),
    MediaItem(
      id: '13',
      title: 'Chernobyl',
      year: 2019,
      type: MediaType.tvShow,
      overview: 'Em abril de 1986, uma explosão na Usina Nuclear de Chernobyl, na União Soviética, torna-se um dos piores desastres causados pelo homem na história do mundo.',
      posterPath: 'https://image.tmdb.org/t/p/w500/v4aMmg9C8f6O7e012S0hMlgfB6d.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/uL6J649zsuiRP8Z23639xxqdTRJ.jpg',
      genres: ['Drama', 'História'],
      seasonsCount: 1,
      ratingImdb: 9.4,
      ratingRottenTomatoes: 95.0,
      ratingTmdb: 8.6,
      streamingPlatforms: [_platforms[3]], // Max
      popularity: 94.0,
    ),
    MediaItem(
      id: '14',
      title: 'The Boys',
      year: 2019,
      type: MediaType.tvShow,
      overview: 'Em um mundo onde super-heróis abraçam o lado mais sombrio de sua fama massiva, um grupo de vigilantes conhecidos como "The Boys" decide derrubar os super-heróis corruptos.',
      posterPath: 'https://image.tmdb.org/t/p/w500/7NsMlzT42d7681uEaf1LafjXl7A.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/w1280/n6bUie03t1g6cHxdoxwQ6n5iSp2.jpg',
      genres: ['Ação', 'Ficção Científica', 'Drama'],
      seasonsCount: 4,
      ratingImdb: 8.7,
      ratingRottenTomatoes: 93.0,
      ratingTmdb: 8.5,
      streamingPlatforms: [_platforms[1]], // Prime Video
      popularity: 97.5,
    ),
  ];

  @override
  Future<List<MediaItem>> searchMedia({
    String? query,
    List<String>? genres,
    String? streamingId,
    MediaType? type,
    String? sortBy,
  }) async {
    // Simula atraso de rede
    await Future.delayed(const Duration(milliseconds: 500));

    List<MediaItem> results = List.from(_items);

    // Filtro por termo de pesquisa
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results.where((item) => item.title.toLowerCase().contains(q)).toList();
    }

    // Filtro por gêneros
    if (genres != null && genres.isNotEmpty) {
      results = results.where((item) {
        return genres.every((genre) => item.genres.contains(genre));
      }).toList();
    }

    // Filtro por plataforma de streaming
    if (streamingId != null && streamingId.isNotEmpty) {
      results = results.where((item) {
        return item.streamingPlatforms.any((platform) => platform.id == streamingId);
      }).toList();
    }

    // Filtro por tipo (Filme ou Série)
    if (type != null) {
      results = results.where((item) => item.type == type).toList();
    }

    // Ordenação
    if (sortBy != null) {
      switch (sortBy) {
        case 'popularity':
          results.sort((a, b) => b.popularity.compareTo(a.popularity));
          break;
        case 'rating':
          results.sort((a, b) => b.displayRating.compareTo(a.displayRating));
          break;
        case 'date':
          results.sort((a, b) => b.year.compareTo(a.year));
          break;
        case 'alphabetical':
          results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
      }
    }

    return results;
  }

  @override
  Future<MediaItem?> getMediaDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MediaItem>> getPopularMedia({MediaType? type}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    List<MediaItem> results = List.from(_items);
    if (type != null) {
      results = results.where((item) => item.type == type).toList();
    }
    results.sort((a, b) => b.popularity.compareTo(a.popularity));
    return results.take(6).toList(); // Retorna top 6 populares
  }

  @override
  Future<List<StreamingPlatform>> getAvailableStreamings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _platforms;
  }

  @override
  Future<List<String>> getAvailableGenres() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final Set<String> genreSet = {};
    for (var item in _items) {
      genreSet.addAll(item.genres);
    }
    return genreSet.toList()..sort();
  }
}
