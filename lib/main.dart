import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'config/router.dart';
import 'providers/repository_providers.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  // Garante inicialização das bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa configuração de ambiente (.env)
  await AppConfig.initialize();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa preferências locais para watchlist persistida
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Sobrescreve o sharedPreferencesProvider com a instância real inicializada
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Onde está o Filme?',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Apenas tema escuro conforme solicitado
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
      scrollBehavior: AppScrollBehavior(),
    );
  }
}
