import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../providers/repository_providers.dart';
import '../widgets/favorite_button.dart';
import '../widgets/genre_chip.dart';
import '../widgets/rating_widget.dart';
import '../widgets/streaming_badge.dart';
import '../widgets/status_widgets.dart';
import '../theme/app_theme.dart';


final mediaDetailsProvider = FutureProvider.family<MediaItem?, String>((ref, id) {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.getMediaDetails(id);
});

class MediaDetailsScreen extends ConsumerWidget {
  final String mediaId;

  const MediaDetailsScreen({
    super.key,
    required this.mediaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(mediaDetailsProvider(mediaId));

    return Scaffold(
      body: detailsAsync.when(
        data: (media) {
          if (media == null) {
            return const Scaffold(
              body: EmptyState(
                title: 'Título não encontrado',
                description: 'Não conseguimos carregar as informações deste filme ou série.',
              ),
            );
          }
          return _buildDetailsBody(context, ref, media);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Scaffold(
          body: ErrorState(
            message: err.toString(),
            onRetry: () => ref.refresh(mediaDetailsProvider(mediaId)),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsBody(BuildContext context, WidgetRef ref, MediaItem media) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seção de Backdrop e Imagem de fundo
          Stack(
            children: [
              // Backdrop Blur
              AspectRatio(
                aspectRatio: isDesktop ? 21 / 9 : 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (media.backdropPath != null)
                      CachedNetworkImage(
                        imageUrl: media.backdropPath!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                      )
                    else
                      Container(color: Colors.grey[900]),
                    // Gradiente de desbotamento escuro
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.darkBackground.withOpacity(0.5),
                              AppTheme.darkBackground,
                            ],
                            stops: const [0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão de voltar
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
              ),
            ],
          ),

          // Seção de Informações Detalhadas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster à esquerda
                      _buildPoster(media, width: 260),
                      const SizedBox(width: 40),
                      // Dados à direita
                      Expanded(child: _buildMediaInfo(context, ref, media)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster centralizado
                      Center(child: _buildPoster(media, width: 200)),
                      const SizedBox(height: 24),
                      // Dados abaixo
                      _buildMediaInfo(context, ref, media),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(MediaItem media, {required double width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: media.posterPath != null
              ? CachedNetworkImage(
                  imageUrl: media.posterPath!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                )
              : Container(color: Colors.grey[900]),
        ),
      ),
    );
  }

  Widget _buildMediaInfo(BuildContext context, WidgetRef ref, MediaItem media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e Botão de Favorito
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${media.year} • ${media.type.label} • ${media.duration ?? "${media.seasonsCount} Temporada(s)"}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FavoriteButton(item: media, size: 28),
          ],
        ),
        const SizedBox(height: 20),

        // Badges de Notas
        RatingWidget(
          ratingImdb: media.ratingImdb,
          ratingRottenTomatoes: media.ratingRottenTomatoes,
          ratingTmdb: media.ratingTmdb,
        ),
        const SizedBox(height: 24),

        // Onde assistir (Destaque Principal)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.play_circle_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Disponível nos streamings (Brasil)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textColorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (media.streamingPlatforms.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: media.streamingPlatforms
                      .map((platform) => StreamingBadge(
                            platform: platform,
                            showName: true,
                            size: 24,
                          ))
                      .toList(),
                )
              else
                const Text(
                  'Este título não está disponível em nenhuma plataforma de streaming cadastrada no momento.',
                  style: TextStyle(
                    color: AppTheme.textColorSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Gêneros
        const Text(
          'Gêneros',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: media.genres.map((g) => GenreChip(label: g)).toList(),
        ),
        const SizedBox(height: 24),

        // Sinopse
        const Text(
          'Sinopse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          media.overview,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textColorPrimary.withOpacity(0.9),
                height: 1.6,
              ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
