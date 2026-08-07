import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_item.dart';
import 'repository_providers.dart';

class WatchlistNotifier extends StateNotifier<List<MediaItem>> {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  WatchlistNotifier(this._ref) : super([]) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Escuta mudanças de auth (login/logout)
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // Se não tiver logado, faz login anônimo
        _auth.signInAnonymously();
      } else {
        // Quando estiver logado, começa a escutar a watchlist do Firestore
        _listenToWatchlist(user.uid);
      }
    });
  }

  void _listenToWatchlist(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .snapshots()
        .listen((snapshot) {
      final items = snapshot.docs.map((doc) {
        return MediaItem.fromJson(doc.data());
      }).toList();
      state = items;
    });
  }

  // Adiciona ou remove da lista de favoritos, persistindo na nuvem
  Future<void> toggleFavorite(MediaItem item) async {
    final user = _auth.currentUser;
    if (user == null) return; // Não deveria acontecer, mas previne erros

    final isFav = state.any((e) => e.id == item.id);
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(item.id);

    if (isFav) {
      await docRef.delete();
      // Remove do storage local como fallback (opcional, mas bom pra offline no app)
      await _ref.read(storageServiceProvider).removeFromWatchlist(item.id);
    } else {
      await docRef.set(item.toJson());
      await _ref.read(storageServiceProvider).addToWatchlist(item);
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

