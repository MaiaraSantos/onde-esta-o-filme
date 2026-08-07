import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class TmdbApiService {
  final http.Client _client;

  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.tmdbBaseUrl}$endpoint').replace(
      queryParameters: {
        'language': 'pt-BR',
        if (queryParams != null) ...queryParams,
        'api_key': AppConfig.tmdbApiKey,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro na API TMDB: ${response.statusCode} - ${response.body}');
    }
  }

  /// Busca TODAS as páginas de um endpoint paginado.
  /// Faz a página 1 primeiro para descobrir total_pages,
  /// depois busca o restante em lotes de 20 requests paralelos.
  Future<List<dynamic>> _getAll(
    String endpoint, {
    Map<String, String>? queryParams,
    int maxPages = 500, // TMDB limita a 500 páginas no máximo
  }) async {
    // Página 1: descobre o total de páginas
    final firstData = await _get(endpoint, queryParams: {
      if (queryParams != null) ...queryParams,
      'page': '1',
    });

    final totalFromApi = (firstData['total_pages'] as num?)?.toInt() ?? 1;
    // Respeita tanto o limite da TMDB (500) quanto o limite do chamador
    final pagesToFetch = min(min(totalFromApi, 500), maxPages);
    final allResults = List<dynamic>.from(firstData['results'] ?? []);

    if (pagesToFetch <= 1) return allResults;

    // Busca páginas restantes em lotes de 20 requests simultâneos
    const batchSize = 20;
    for (int start = 2; start <= pagesToFetch; start += batchSize) {
      final end = min(start + batchSize - 1, pagesToFetch);
      final batch = await Future.wait([
        for (int page = start; page <= end; page++)
          _get(endpoint, queryParams: {
            if (queryParams != null) ...queryParams,
            'page': '$page',
          }),
      ]);
      for (final pageData in batch) {
        allResults.addAll(pageData['results'] ?? []);
      }
    }

    return allResults;
  }

  Future<List<dynamic>> getPopular({String type = 'movie', int maxPages = 5}) async {
    return _getAll('/$type/popular', maxPages: maxPages);
  }

  Future<List<dynamic>> search(String query, {int maxPages = 500}) async {
    return _getAll('/search/multi', queryParams: {'query': query}, maxPages: maxPages);
  }

  Future<Map<String, dynamic>> getDetails(String id, String type) async {
    final data = await _get('/$type/$id', queryParams: {'append_to_response': 'external_ids'});
    return data;
  }

  Future<List<dynamic>> getGenres(String type) async {
    final data = await _get('/genre/$type/list');
    return data['genres'] ?? [];
  }

  Future<List<dynamic>> discover({
    String type = 'movie',
    Map<String, String>? params,
    int maxPages = 500,
  }) async {
    return _getAll('/discover/$type', queryParams: params, maxPages: maxPages);
  }
}
