import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../providers/search_providers.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/filter_panel.dart';
import '../widgets/movie_card.dart';
import '../widgets/horizontal_media_list.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/status_widgets.dart';
import '../widgets/logo_widget.dart';
import '../widgets/rating_widget.dart';
import '../widgets/streaming_badge.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? initialPlatform;
  final String? initialGenre;
  final String? initialType;

  const HomeScreen({
    super.key,
    this.initialQuery,
    this.initialPlatform,
    this.initialGenre,
    this.initialType,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0; // 0 = Início, 1 = Descobrir, 2 = Quero Assistir
  final TextEditingController _topSearchController = TextEditingController();
  bool _isFilterExpanded = true;
  final ScrollController _discoverScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listener de scroll para infinite scroll
    _discoverScrollController.addListener(_onDiscoverScroll);
    // Preenche filtros iniciais se vierem pela URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool hasInitialFilters = false;
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery!;
        _topSearchController.text = widget.initialQuery!;
        hasInitialFilters = true;
      }
      if (widget.initialPlatform != null) {
        ref.read(selectedPlatformProvider.notifier).state =
            widget.initialPlatform;
        hasInitialFilters = true;
      }
      if (widget.initialGenre != null) {
        ref.read(selectedGenresProvider.notifier).state = [
          widget.initialGenre!,
        ];
        hasInitialFilters = true;
      }
      if (widget.initialType != null) {
        final type = widget.initialType == 'tvShow'
            ? MediaType.tvShow
            : MediaType.movie;
        ref.read(selectedTypeProvider.notifier).state = type;
        hasInitialFilters = true;
      }

      if (hasInitialFilters) {
        setState(() {
          _currentTab = 1; // Redireciona para aba Descobrir
        });
      }
    });
  }

  @override
  void dispose() {
    _topSearchController.dispose();
    _discoverScrollController.dispose();
    super.dispose();
  }

  void _onDiscoverScroll() {
    final position = _discoverScrollController.position;
    // Carrega mais quando estiver a 300px do fundo
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(paginatedSearchProvider.notifier).loadMore();
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchQueryProvider.notifier).state = query;
      setState(() {
        _currentTab = 1; // Vai para aba Descobrir
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar Lateral esquerda (Apenas no Desktop)
            if (isDesktop) _buildSidebar(context, watchlist.length),

            // Área de Conteúdo Principal
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildTabContent(context),
              ),
            ),
          ],
        ),
      ),
      // Navegação Inferior para Dispositivos Móveis e Tablets
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _currentTab,
              onTap: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
              backgroundColor: AppTheme.darkSurface,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textColorSecondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Início',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  label: 'Descobrir',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('${watchlist.length}'),
                    isLabelVisible: watchlist.isNotEmpty,
                    child: const Icon(Icons.bookmark_outline_rounded),
                  ),
                  label: 'Salvos',
                ),
              ],
            )
          : null,
    );
  }

  // --- WIDGET DA BARRA SUPERIOR ---
  Widget _buildTopBar(
    BuildContext context,
    bool isDesktop,
    int watchlistCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Logo no Mobile
          if (!isDesktop) ...[
            const LogoWidget(showText: false, iconSize: 24),
            const SizedBox(width: 12),
          ],

          // Barra de busca do topo (Redireciona para aba Descobrir ao buscar)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: TextField(
                controller: _topSearchController,
                onSubmitted: _onSearchSubmitted,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Pesquise por títulos ou streamings...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textColorSecondary,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  fillColor: AppTheme.darkSurface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  suffixIcon: _topSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _topSearchController.clear();
                            });
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

            // Botão Quero Assistir no topo no Mobile/Tablet (Apenas atalho rápido)
          if (!isDesktop) ...[
            IconButton(
              icon: Badge(
                label: Text('$watchlistCount'),
                isLabelVisible: watchlistCount > 0,
                child: const Icon(Icons.bookmark_rounded),
              ),
              onPressed: () {
                setState(() {
                  _currentTab = 2; // Vai para a Watchlist
                });
              },
            ),
            const SizedBox(width: 8),
          ],
          
          // Botão de Perfil/Login com Google
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(authProvider);
              final isAnonymous = user?.isAnonymous ?? true;

              if (isAnonymous) {
                return OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).linkWithGoogle();
                  },
                  icon: const Icon(Icons.cloud_sync_rounded, size: 18),
                  label: const Text('Login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: isDesktop
                        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                );
              } else {
                return PopupMenuButton<String>(
                  tooltip: 'Sua conta Google',
                  onSelected: (val) {
                    if (val == 'logout') {
                      ref.read(authProvider.notifier).signOut();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        user?.email ?? 'Usuário',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Sair', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    backgroundImage: user?.photoURL != null
                        ? CachedNetworkImageProvider(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, color: AppTheme.primaryColor)
                        : null,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET DA SIDEBAR (DESKTOP) ---
  Widget _buildSidebar(BuildContext context, int watchlistCount) {
    return Container(
      width: 240,
      color: AppTheme.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Principal
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: LogoWidget(fontSize: 18, iconSize: 28),
          ),
          const SizedBox(height: 36),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              'MENU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Itens de Navegação
          _buildSidebarNavItem(
            icon: Icons.home_filled,
            label: 'Início',
            index: 0,
          ),
          _buildSidebarNavItem(
            icon: Icons.explore_outlined,
            label: 'Descobrir',
            index: 1,
          ),
          _buildSidebarNavItem(
            icon: Icons.bookmark_outline_rounded,
            label: 'Quero Assistir',
            index: 2,
            badgeCount: watchlistCount > 0 ? watchlistCount : null,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required int index,
    int? badgeCount,
  }) {
    final isSelected = _currentTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTab = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textColorSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textColorSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- RETORNA O CONTEÚDO CORRESPONDENTE A CADA ABA ---
  Widget _buildTabContent(BuildContext context) {
    switch (_currentTab) {
      case 0:
        return _buildHomeTab(context);
      case 1:
        return _buildDiscoverTab(context);
      case 2:
        return _buildWatchlistTab(context);
      default:
        return _buildHomeTab(context);
    }
  }

  // ==========================================
  // ABA 0: INÍCIO (DASHBOARD COM HERO BANNER E HORIZONTAL SCROLL)
  // ==========================================
  Widget _buildHomeTab(BuildContext context) {
    final popularAsync = ref.watch(popularMediaProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;
    final watchlist = ref.watch(watchlistProvider);

    return Column(
      children: [
        _buildTopBar(context, isDesktop, watchlist.length),
        Expanded(
          child: popularAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Nenhum título encontrado'));
              }

              // Escolhe o primeiro item da lista de populares para ser o destaque (Hero)
              final heroItem = items.first;
              final listWithoutHero = items.skip(1).toList();

              // Filtra séries para a segunda seção
              final seriesList = items
                  .where((item) => item.type == MediaType.tvShow)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HERO BANNER DE DESTAQUE
                    _buildHeroBanner(context, heroItem),
                    const SizedBox(height: 36),

                    // 2. MAIS POPULARES NO BRASIL (Rolagem Horizontal)
                    // 2. MAIS POPULARES NO BRASIL (Rolagem Horizontal com Setas)
                    HorizontalMediaList(
                      title: 'Mais Populares no Brasil 🔥',
                      items: listWithoutHero,
                    ),
                    const SizedBox(height: 36),

                    // 3. SÉRIES EM DESTAQUE (Rolagem Horizontal com Setas)
                    if (seriesList.isNotEmpty) ...[
                      HorizontalMediaList(
                        title: 'Séries em Destaque 📺',
                        items: seriesList,
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ErrorState(
              message: 'Erro ao carregar conteúdo inicial: ${err.toString()}',
              onRetry: () => ref.refresh(popularMediaProvider),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET DO HERO BANNER (ESTILO NETFLIX / DISNEY+)
  Widget _buildHeroBanner(BuildContext context, MediaItem heroItem) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 600;
    final watchlist = ref.watch(watchlistProvider);
    final isInWatchlist = watchlist.any((e) => e.id == heroItem.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      height: isCompact ? 280 : 420,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem de Backdrop
            heroItem.backdropPath != null
                ? CachedNetworkImage(
                    imageUrl: heroItem.backdropPath!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey[900]),
                  )
                : Container(color: Colors.grey[900]),

            // Gradiente Escuro de Overlay (Fade-out para a esquerda e para a base)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.95),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Informações do Filme sobrepostas
            Padding(
              padding: EdgeInsets.all(isCompact ? 16.0 : 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Badge "Trending Now" / Destaque do Dia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppTheme.primaryColor,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'DESTAQUE DE HOJE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título Principal
                  Text(
                    heroItem.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadados (Ano • Tipo • Duração • Notas)
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${heroItem.year} • ${heroItem.type.label}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (heroItem.duration != null)
                        Text(
                          heroItem.duration!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      if (heroItem.seasonsCount != null)
                        Text(
                          '${heroItem.seasonsCount} temp.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5C518),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'IMDb ${heroItem.ratingImdb?.toStringAsFixed(1) ?? heroItem.ratingTmdb.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Sinopse Curta (Não exibe em telas muito pequenas)
                  if (!isCompact) ...[
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Text(
                        heroItem.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Plataformas de streaming onde está disponível
                  if (heroItem.streamingPlatforms.isNotEmpty) ...[
                    const Text(
                      'Disponível em:',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: heroItem.streamingPlatforms.take(4).map((
                        platform,
                      ) {
                        return StreamingBadge(platform: platform, size: 22);
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botões de Ação
                  Row(
                    children: [
                      // Botão "Assistir / Detalhes"
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 16 : 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.push('/title/${heroItem.id}');
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 20),
                        label: const Text(
                          'Ver Onde Assistir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botão "Adicionar à Watchlist"
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 16 : 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(watchlistProvider.notifier)
                              .toggleFavorite(heroItem);

                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !isInWatchlist
                                    ? 'Adicionado à Watchlist!'
                                    : 'Removido da Watchlist!',
                                style: TextStyle(
                                  color: !isInWatchlist ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: !isInWatchlist
                                  ? AppTheme.primaryColor
                                  : Colors.grey[900],
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(
                          isInWatchlist
                              ? Icons.check_rounded
                              : Icons.bookmark_add_outlined,
                          size: 20,
                        ),
                        label: Text(
                          isInWatchlist ? 'Salvo' : 'Quero Assistir',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ABA 1: DESCOBRIR (FILTROS LATERAIS E GRID DE RESULTADOS)
  // ==========================================
  Widget _buildDiscoverTab(BuildContext context) {
    final searchState = ref.watch(paginatedSearchProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;
    final watchlist = ref.watch(watchlistProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPanelPinned = constraints.maxWidth > 850;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Painel Lateral Fixo de Filtros (Somente em Desktop/Telas Largas)
            if (isPanelPinned)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isFilterExpanded ? 300 : 96,
                child: ClipRect(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 16,
                        left: 24,
                        bottom: 24,
                        right: _isFilterExpanded ? 8 : 24,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                        width: _isFilterExpanded ? 268 : 48,
                        child: FilterPanel(
                          isExpanded: _isFilterExpanded,
                          onToggle: () {
                            setState(() {
                              _isFilterExpanded = !_isFilterExpanded;
                            });
                          },
                          onClear: () {
                            ref.read(resetFiltersProvider)();
                            _topSearchController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Área Principal com Resultados
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context, isDesktop, watchlist.length),
                  // Cabeçalho / Informação de Busca Ativa
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (searchState.isLoading)
                          const Text(
                            'Buscando...',
                            style: TextStyle(color: Colors.white54),
                          )
                        else
                          Text(
                            '${searchState.items.length}${searchState.hasMore ? '+' : ''} título(s) encontrado(s)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                        // Botão para abrir filtros em telas menores (BottomSheet/Modal)
                        if (!isPanelPinned)
                          TextButton.icon(
                            onPressed: () {
                              _showMobileFiltersModal(context);
                            },
                            icon: const Icon(Icons.filter_list_rounded),
                            label: const Text('Filtros'),
                          ),
                      ],
                    ),
                  ),

                  // Grid de Resultados
                  Expanded(
                    child: searchState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: LoadingWidget(),
                          )
                        : searchState.error != null
                            ? ErrorState(
                                message: 'Falha na requisição: ${searchState.error}',
                                onRetry: () => ref
                                    .read(paginatedSearchProvider.notifier)
                                    .loadMore(),
                              )
                            : searchState.items.isEmpty
                                ? const EmptyState()
                                : GridView.builder(
                                    controller: _discoverScrollController,
                                    padding: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      top: 16,
                                      bottom: 80, // espaço para o loading indicator
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 220,
                                          childAspectRatio: 170 / 350,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    // +1 para o item de loading no fundo quando isLoadingMore
                                    itemCount: searchState.items.length +
                                        (searchState.isLoadingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == searchState.items.length) {
                                        // Loading spinner no fundo
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      }
                                      return MovieCard(item: searchState.items[index]);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BottomSheet para exibir filtros de forma limpa no Mobile
  void _showMobileFiltersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra indicadora de arrastar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FilterPanel(
                    onClear: () {
                      ref.read(resetFiltersProvider)();
                      _topSearchController.clear();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // ABA 2: QUERO ASSISTIR (GRID DE FAVORITOS PERSISTIDOS)
  // ==========================================
  Widget _buildWatchlistTab(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950;

    return Column(
      children: [
        _buildTopBar(context, isDesktop, watchlist.length),
        Expanded(
          child: watchlist.isEmpty
              ? EmptyState(
                  title: 'Sua watchlist está vazia',
                  description:
                      'Explore títulos na busca e salve seus filmes ou séries preferidos aqui para assistir depois.',
                  actionLabel: 'Começar a descobrir',
                  onActionPressed: () {
                    setState(() {
                      _currentTab = 1; // Leva o usuário para aba Descobrir
                    });
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Text(
                        'Você salvou ${watchlist.length} título(s) para assistir.',
                        style: const TextStyle(
                          color: AppTheme.textColorSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              childAspectRatio: 170 / 350,
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
      ],
    );
  }
}
