enum MediaType {
  movie,
  tvShow;

  String get label {
    switch (this) {
      case MediaType.movie:
        return 'Filme';
      case MediaType.tvShow:
        return 'Série';
    }
  }
}

class StreamingPlatform {
  final String id;
  final String name;
  final String? logoUrl;
  final String? url; // Link direto para assistir se disponível

  const StreamingPlatform({
    required this.id,
    required this.name,
    this.logoUrl,
    this.url,
  });

  factory StreamingPlatform.fromJson(Map<String, dynamic> json) {
    return StreamingPlatform(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'url': url,
    };
  }
}

class MediaItem {
  final String id;
  final String title;
  final int year;
  final MediaType type;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<String> genres;
  final String? duration; // Para filmes (ex: "1h 48min")
  final int? seasonsCount; // Para séries
  final double? ratingImdb;
  final double? ratingRottenTomatoes; // Em porcentagem (ex: 94.0)
  final double ratingTmdb;
  final List<StreamingPlatform> streamingPlatforms;
  final double popularity;

  const MediaItem({
    required this.id,
    required this.title,
    required this.year,
    required this.type,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.genres,
    this.duration,
    this.seasonsCount,
    this.ratingImdb,
    this.ratingRottenTomatoes,
    required this.ratingTmdb,
    required this.streamingPlatforms,
    required this.popularity,
  });

  // Getter para obter a nota principal a ser exibida, com fallback
  double get displayRating {
    if (ratingImdb != null) return ratingImdb!;
    if (ratingRottenTomatoes != null) return ratingRottenTomatoes! / 10.0;
    return ratingTmdb;
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      year: json['year'] as int? ?? 0,
      type: json['type'] == 'tvShow' ? MediaType.tvShow : MediaType.movie,
      overview: json['overview']?.toString() ?? '',
      posterPath: json['poster_path']?.toString(),
      backdropPath: json['backdrop_path']?.toString(),
      genres: List<String>.from(json['genres'] ?? []),
      duration: json['duration']?.toString(),
      seasonsCount: json['seasons_count'] as int?,
      ratingImdb: (json['rating_imdb'] as num?)?.toDouble(),
      ratingRottenTomatoes: (json['rating_rotten_tomatoes'] as num?)?.toDouble(),
      ratingTmdb: (json['rating_tmdb'] as num?)?.toDouble() ?? 0.0,
      streamingPlatforms: (json['streaming_platforms'] as List?)
              ?.map((e) => StreamingPlatform.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'type': type == MediaType.tvShow ? 'tvShow' : 'movie',
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'genres': genres,
      'duration': duration,
      'seasons_count': seasonsCount,
      'rating_imdb': ratingImdb,
      'rating_rotten_tomatoes': ratingRottenTomatoes,
      'rating_tmdb': ratingTmdb,
      'streaming_platforms': streamingPlatforms.map((e) => e.toJson()).toList(),
      'popularity': popularity,
    };
  }

  MediaItem copyWith({
    String? id,
    String? title,
    int? year,
    MediaType? type,
    String? overview,
    String? posterPath,
    String? backdropPath,
    List<String>? genres,
    String? duration,
    int? seasonsCount,
    double? ratingImdb,
    double? ratingRottenTomatoes,
    double? ratingTmdb,
    List<StreamingPlatform>? streamingPlatforms,
    double? popularity,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      type: type ?? this.type,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      seasonsCount: seasonsCount ?? this.seasonsCount,
      ratingImdb: ratingImdb ?? this.ratingImdb,
      ratingRottenTomatoes: ratingRottenTomatoes ?? this.ratingRottenTomatoes,
      ratingTmdb: ratingTmdb ?? this.ratingTmdb,
      streamingPlatforms: streamingPlatforms ?? this.streamingPlatforms,
      popularity: popularity ?? this.popularity,
    );
  }
}
