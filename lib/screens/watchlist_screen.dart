import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/status_widgets.dart';
import '../theme/app_theme.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        title: Text(
          'Quero Assistir',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SafeArea(
        child: watchlist.isEmpty
            ? EmptyState(
                title: 'Sua lista está vazia',
                description: 'Explore títulos na busca e adicione marcadores para salvá-los aqui.',
                actionLabel: 'Começar a descobrir',
                onActionPressed: () {
                  context.go('/');
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Você possui ${watchlist.length} título(s) salvo(s) para assistir depois.',
                      style: const TextStyle(
                        color: AppTheme.textColorSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 2 / 3.4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: watchlist.length,
                      itemBuilder: (context, index) {
                        return MovieCard(item: watchlist[index]);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
