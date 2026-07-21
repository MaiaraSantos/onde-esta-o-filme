import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';
import 'repository_providers.dart';

// Provedores para o estado dos filtros de busca
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedPlatformProvider = StateProvider<String?>((ref) => null);
final selectedGenresProvider = StateProvider<List<String>>((ref) => []);
final selectedTypeProvider = StateProvider<MediaType?>((ref) => null);
final sortByProvider = StateProvider<String>((ref) => 'popularity');

// Provedor para verificar se o usuário fez alguma ação de busca/filtro
final isSearchActiveProvider = Provider<bool>((ref) {
  final query = ref.watch(searchQueryProvider);
  final platform = ref.watch(selectedPlatformProvider);
  final genres = ref.watch(selectedGenresProvider);
  final type = ref.watch(selectedTypeProvider);

  return query.trim().isNotEmpty || platform != null || genres.isNotEmpty || type != null;
});

// Provedor que executa a busca combinando todos os filtros reativamente
final searchResultsProvider = FutureProvider<List<MediaItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final platform = ref.watch(selectedPlatformProvider);
  final genres = ref.watch(selectedGenresProvider);
  final type = ref.watch(selectedTypeProvider);
  final sortBy = ref.watch(sortByProvider);
  final repo = ref.watch(mediaRepositoryProvider);

  return repo.searchMedia(
    query: query,
    genres: genres,
    streamingId: platform,
    type: type,
    sortBy: sortBy,
  );
});

// Provedor de gêneros disponíveis
final availableGenresProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(mediaRepositoryProvider).getAvailableGenres();
});

// Provedor de plataformas de streaming disponíveis
final availablePlatformsProvider = FutureProvider<List<StreamingPlatform>>((ref) {
  return ref.watch(mediaRepositoryProvider).getAvailableStreamings();
});

// Provedor para obter itens populares na Home
final popularMediaProvider = FutureProvider<List<MediaItem>>((ref) {
  return ref.watch(mediaRepositoryProvider).getPopularMedia();
});

// Método utilitário para resetar todos os filtros
final resetFiltersProvider = Provider((ref) {
  return () {
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedPlatformProvider.notifier).state = null;
    ref.read(selectedGenresProvider.notifier).state = [];
    ref.read(selectedTypeProvider.notifier).state = null;
    ref.read(sortByProvider.notifier).state = 'popularity';
  };
});
