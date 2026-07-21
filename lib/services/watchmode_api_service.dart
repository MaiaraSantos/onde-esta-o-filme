import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/media_item.dart';

class WatchmodeApiService {
  final http.Client _client;

  WatchmodeApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.watchmodeBaseUrl}$endpoint').replace(
      queryParameters: {
        'apiKey': AppConfig.watchmodeApiKey,
        'regions': AppConfig.defaultCountry,
        if (queryParams != null) ...queryParams,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro na API Watchmode: ${response.statusCode} - ${response.body}');
    }
  }

  /// Retorna as fontes de streaming para um ID do TMDB.
  /// O Watchmode suporta o uso do TMDB ID prefixando com 'movie-' ou 'tv-'.
  Future<List<StreamingPlatform>> getStreamingSources(String tmdbId, MediaType type) async {
    if (AppConfig.useMockData) {
      return []; // Proteção contra consumo acidental da cota
    }
    
    final typePrefix = type == MediaType.movie ? 'movie' : 'tv';
    final watchmodeId = '$typePrefix-$tmdbId';
    
    try {
      final data = await _get('/title/$watchmodeId/sources/');
      if (data is List) {
        return data.map((source) {
          return StreamingPlatform(
            id: source['source_id']?.toString() ?? '',
            name: source['name']?.toString() ?? 'Desconhecido',
            url: source['web_url']?.toString(),
            // Watchmode geralmente não retorna logo_url nessa chamada básica
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar fontes de streaming: $e');
      return [];
    }
  }
}
