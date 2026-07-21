import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/media_repository.dart';
import '../repositories/mock_media_repository.dart';
import '../services/storage_service.dart';

import '../services/tmdb_api_service.dart';
import '../services/watchmode_api_service.dart';
import '../repositories/api_media_repository.dart';
import '../config/app_config.dart';

// O SharedPreferences será obtido de forma assíncrona no main e injetado aqui
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('O SharedPreferencesProvider deve ser sobrescrito no main.dart');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

final tmdbApiServiceProvider = Provider<TmdbApiService>((ref) {
  return TmdbApiService();
});

final watchmodeApiServiceProvider = Provider<WatchmodeApiService>((ref) {
  return WatchmodeApiService();
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockMediaRepository();
  }
  
  final tmdbService = ref.watch(tmdbApiServiceProvider);
  final watchmodeService = ref.watch(watchmodeApiServiceProvider);
  return ApiMediaRepository(tmdbService, watchmodeService);
});
