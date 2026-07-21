import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';
import 'streaming_badge.dart';

class MovieCard extends StatelessWidget {
  final MediaItem item;

  const MovieCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push('/title/${item.id}');
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster com Overlay de Favorito e Nota
              AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagem de Poster com cached_network_image
                    item.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: item.posterPath!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white.withOpacity(0.05),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[900],
                              child: const Icon(Icons.movie, size: 50, color: Colors.white24),
                            ),
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.movie, size: 50, color: Colors.white24),
                          ),
                    // Sombra gradiente suave na parte inferior
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.6, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Botão Favorito no canto superior direito
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FavoriteButton(item: item, size: 20),
                    ),
                    // Badge de Tipo (Filme / Série) no canto superior esquerdo
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          item.type.label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conteúdo de texto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Título e Ano
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (item.year > 0) '${item.year}',
                              if (item.duration != null) item.duration,
                              if (item.duration == null && item.seasonsCount != null) '${item.seasonsCount} temp.'
                            ].join(' • '),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                      // Streamings disponíveis e Nota
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nota Principal
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFF5C518), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                item.displayRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          // Streamings Badges
                          if (item.streamingPlatforms.isNotEmpty)
                            Wrap(
                              spacing: -6, // Sobreposição leve estilosa
                              children: item.streamingPlatforms
                                  .take(3)
                                  .map((p) => Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.darkSurfaceCard,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: StreamingBadge(platform: p, size: 20),
                                      ))
                                  .toList(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
