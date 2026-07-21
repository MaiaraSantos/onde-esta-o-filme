import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Fallback ou tratamento se o .env não existir (útil em produção na web se não empacotado corretamente)
      // Mas definimos no pubspec.yaml assets como .env
    }
  }

  static String get env => dotenv.env['APP_ENV'] ?? 'dev';
  static bool get isDev => env == 'dev';

  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbBaseUrl => dotenv.env['TMDB_BASE_URL'] ?? 'https://api.themoviedb.org/3';
  static String get tmdbImageBaseUrl => dotenv.env['TMDB_IMAGE_BASE_URL'] ?? 'https://image.tmdb.org/t/p';

  static String get watchmodeApiKey => dotenv.env['WATCHMODE_API_KEY'] ?? '';
  static String get watchmodeBaseUrl => dotenv.env['WATCHMODE_BASE_URL'] ?? 'https://api.watchmode.com/v1';

  // Configurações globais
  static const String defaultCountry = 'BR'; // Foco em Brasil
  
  // Feature Flags
  static const bool useMockData = false;            // Use true para não consumir cota do Watchmode no dev
  static const bool enableRecommendations = false; // Preparação para o futuro
  static const bool enableTrailers = false;        // Preparação para o futuro
}
