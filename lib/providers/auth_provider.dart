import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(FirebaseAuth.instance.currentUser) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  /// Vincula a conta anônima atual com uma conta Google
  Future<void> linkWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        
        await user.linkWithPopup(provider);
      }
    } on FirebaseAuthException catch (e) {
      // Se a conta Google já existir e estiver atrelada a outro UID,
      // devemos lidar com a mescla ou apenas avisar o erro.
      // O erro 'credential-already-in-use' é comum aqui.
      if (e.code == 'credential-already-in-use') {
        // Solução simples: se já existe, nós apenas fazemos o login direto.
        // O usuário perderia a lista anônima atual e baixaria a lista antiga dele.
        final credential = e.credential;
        if (credential != null) {
          await _auth.signInWithCredential(credential);
        }
      } else {
        rethrow;
      }
    }
  }

  /// Faz logout (se for conta Google, ele volta pra uma nova anônima)
  Future<void> signOut() async {
    await _auth.signOut();
    // O WatchlistNotifier já está escutando authStateChanges,
    // e criará um novo login anônimo imediatamente após este signOut!
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
