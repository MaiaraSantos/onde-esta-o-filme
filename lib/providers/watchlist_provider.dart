import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';
import 'repository_providers.dart';

class WatchlistNotifier extends StateNotifier<List<MediaItem>> {
  final Ref _ref;

  WatchlistNotifier(this._ref) : super([]) {
    _loadWatchlist();
  }

  // Carrega os itens salvos do SharedPreferences
  void _loadWatchlist() {
    final storage = _ref.read(storageServiceProvider);
    state = storage.getWatchlist();
  }

  // Adiciona ou remove da lista de favoritos, persistindo localmente
  Future<void> toggleFavorite(MediaItem item) async {
    final storage = _ref.read(storageServiceProvider);
    final isFav = state.any((e) => e.id == item.id);

    if (isFav) {
      await storage.removeFromWatchlist(item.id);
      state = state.where((e) => e.id != item.id).toList();
    } else {
      await storage.addToWatchlist(item);
      state = [...state, item];
    }
  }

  // Verifica se um item é favorito
  bool isFavorite(String id) {
    return state.any((e) => e.id == id);
  }
}

// Provedor global para gerenciar o estado da Watchlist ("Quero assistir")
final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<MediaItem>>((ref) {
  return WatchlistNotifier(ref);
});
