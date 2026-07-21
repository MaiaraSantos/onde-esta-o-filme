import 'dart:convert';
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

  Future<List<dynamic>> getPopular({String type = 'movie'}) async {
    final data = await _get('/$type/popular');
    return data['results'] ?? [];
  }

  Future<List<dynamic>> search(String query) async {
    final data = await _get('/search/multi', queryParams: {'query': query});
    return data['results'] ?? [];
  }

  Future<Map<String, dynamic>> getDetails(String id, String type) async {
    final data = await _get('/$type/$id', queryParams: {'append_to_response': 'external_ids'});
    return data;
  }

  Future<List<dynamic>> getGenres(String type) async {
    final data = await _get('/genre/$type/list');
    return data['genres'] ?? [];
  }

  Future<List<dynamic>> discover({String type = 'movie', Map<String, String>? params}) async {
    final data = await _get('/discover/$type', queryParams: params);
    return data['results'] ?? [];
  }
}
