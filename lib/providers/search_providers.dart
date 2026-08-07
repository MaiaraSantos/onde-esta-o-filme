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

// ============================================================
// INFINITE SCROLL — estado paginado para a aba Descobrir
// ============================================================

class PaginatedSearchState {
  final List<MediaItem> items;
  final bool isLoading;      // Carregamento inicial (página 1)
  final bool isLoadingMore;  // Carregando próxima página (scroll)
  final bool hasMore;        // Ainda há páginas por carregar
  final String? error;

  const PaginatedSearchState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedSearchState copyWith({
    List<MediaItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedSearchState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class PaginatedSearchNotifier extends StateNotifier<PaginatedSearchState> {
  PaginatedSearchNotifier(this._ref) : super(const PaginatedSearchState()) {
    // Reseta e recarrega sempre que qualquer filtro mudar
    _ref.listen<String>(searchQueryProvider, (_, __) => _reset());
    _ref.listen<List<String>>(selectedGenresProvider, (_, __) => _reset());
    _ref.listen<String?>(selectedPlatformProvider, (_, __) => _reset());
    _ref.listen<MediaType?>(selectedTypeProvider, (_, __) => _reset());
    _ref.listen<String>(sortByProvider, (_, __) => _reset());
    _reset();
  }

  final Ref _ref;
  int _page = 0;
  int _totalPages = 1;
  bool _isFetching = false;

  /// Reseta o estado e carrega a primeira página
  void _reset() {
    _page = 0;
    _totalPages = 1;
    _isFetching = false;
    state = const PaginatedSearchState(
      items: [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
    );
    _loadNextPage();
  }

  /// Carrega a próxima página (chamado pelo scroll listener)
  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isFetching) return;
    final nextPage = _page + 1;
    if (_page > 0 && nextPage > _totalPages) {
      state = state.copyWith(isLoadingMore: false, hasMore: false);
      return;
    }

    _isFetching = true;
    try {
      final query = _ref.read(searchQueryProvider);
      final genres = _ref.read(selectedGenresProvider);
      final platform = _ref.read(selectedPlatformProvider);
      final type = _ref.read(selectedTypeProvider);
      final sortBy = _ref.read(sortByProvider);
      final repo = _ref.read(mediaRepositoryProvider);

      final result = await repo.searchMediaPaged(
        query: query.trim().isEmpty ? null : query.trim(),
        genres: genres.isEmpty ? null : genres,
        streamingId: platform,
        type: type,
        sortBy: sortBy,
        page: nextPage,
      );

      _page = nextPage;
      _totalPages = result.totalPages;

      final allItems = nextPage == 1
          ? result.items
          : [...state.items, ...result.items];

      state = PaginatedSearchState(
        items: allItems,
        isLoading: false,
        isLoadingMore: false,
        hasMore: nextPage < _totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    } finally {
      _isFetching = false;
    }
  }
}

/// Provider principal de resultados — suporta infinite scroll
final paginatedSearchProvider =
    StateNotifierProvider.autoDispose<PaginatedSearchNotifier, PaginatedSearchState>(
  (ref) => PaginatedSearchNotifier(ref),
);

// Provedor legado — mantido para compatibilidade com outros widgets
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
