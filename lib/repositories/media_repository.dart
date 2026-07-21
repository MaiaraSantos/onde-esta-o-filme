import '../models/media_item.dart';

abstract class MediaRepository {
  /// Realiza busca por nome, filtros de gêneros, streaming, tipo (filme/série) e ordenação.
  Future<List<MediaItem>> searchMedia({
    String? query,
    List<String>? genres,
    String? streamingId,
    MediaType? type,
    String? sortBy, // 'popularity', 'rating', 'date', 'alphabetical'
  });

  /// Busca os detalhes de um título específico por ID
  Future<MediaItem?> getMediaDetails(String id);

  /// Retorna os títulos populares para a Home / Seção de destaque
  Future<List<MediaItem>> getPopularMedia({MediaType? type});

  /// Retorna as plataformas de streaming disponíveis
  Future<List<StreamingPlatform>> getAvailableStreamings();

  /// Retorna todos os gêneros disponíveis
  Future<List<String>> getAvailableGenres();
}
