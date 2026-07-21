import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/media_details_screen.dart';
import '../screens/watchlist_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        // Pega parâmetros de busca da URL (opcional, bom para links diretos)
        final query = state.uri.queryParameters['q'];
        final platform = state.uri.queryParameters['platform'];
        final genre = state.uri.queryParameters['genre'];
        final type = state.uri.queryParameters['type'];
        
        return HomeScreen(
          initialQuery: query,
          initialPlatform: platform,
          initialGenre: genre,
          initialType: type,
        );
      },
    ),
    GoRoute(
      path: '/title/:id',
      name: 'details',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return MediaDetailsScreen(mediaId: id);
      },
    ),
    GoRoute(
      path: '/watchlist',
      name: 'watchlist',
      builder: (context, state) {
        return const WatchlistScreen();
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.error}'),
    ),
  ),
);
