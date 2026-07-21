import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';
import '../providers/search_providers.dart';
import '../theme/app_theme.dart';
import 'genre_chip.dart';
import 'streaming_badge.dart';

class FilterPanel extends ConsumerWidget {
  final VoidCallback? onClear;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const FilterPanel({
    super.key, 
    this.onClear,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isExpanded) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white70),
            onPressed: onToggle,
            tooltip: 'Expandir Filtros',
          ),
        ),
      );
    }
    final selectedType = ref.watch(selectedTypeProvider);
    final selectedPlatform = ref.watch(selectedPlatformProvider);
    final selectedGenres = ref.watch(selectedGenresProvider);
    final sortBy = ref.watch(sortByProvider);

    final platformsAsync = ref.watch(availablePlatformsProvider);
    final genresAsync = ref.watch(availableGenresProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Painel (Título, Toggle e Botão Limpar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filtros',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_left, size: 20, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              if (onClear != null)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          // Tipo & Ordenação (Lado a lado no Desktop, coluna no Mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 500;
              final content = [
                // Filtro de Tipo
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTypeButton(ref, null, 'Todos', selectedType == null),
                          const SizedBox(width: 8),
                          _buildTypeButton(ref, MediaType.movie, 'Filmes', selectedType == MediaType.movie),
                          const SizedBox(width: 8),
                          _buildTypeButton(ref, MediaType.tvShow, 'Séries', selectedType == MediaType.tvShow),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isDesktop) const SizedBox(height: 16),
                // Ordenação
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ordenar por',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: sortBy,
                        dropdownColor: AppTheme.darkSurface,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'popularity', child: Text('Popularidade')),
                          DropdownMenuItem(value: 'rating', child: Text('Melhor Nota')),
                          DropdownMenuItem(value: 'date', child: Text('Mais Recentes')),
                          DropdownMenuItem(value: 'alphabetical', child: Text('Ordem Alfabética')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(sortByProvider.notifier).state = val;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ];

              return isDesktop
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: content)
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: content);
            },
          ),
          const Divider(height: 32, color: Colors.white10),

          // Filtro de Streamings
          const Text(
            'Plataforma de Streaming',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          platformsAsync.when(
            data: (platforms) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Opção "Todos"
                GestureDetector(
                  onTap: () => ref.read(selectedPlatformProvider.notifier).state = null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedPlatform == null
                          ? AppTheme.primaryColor
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selectedPlatform == null
                            ? AppTheme.primaryColor
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      'Todas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selectedPlatform == null ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
                ...platforms.map((platform) {
                  final isSelected = selectedPlatform == platform.id;
                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedPlatformProvider.notifier).state =
                          isSelected ? null : platform.id;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white.withOpacity(0.08),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamingBadge(platform: platform, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            platform.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppTheme.primaryColor : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Erro ao carregar plataformas'),
          ),

          const Divider(height: 32, color: Colors.white10),

          // Filtro de Gêneros
          const Text(
            'Gêneros',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          genresAsync.when(
            data: (genres) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((genre) {
                final isSelected = selectedGenres.contains(genre);
                return GenreChip(
                  label: genre,
                  isSelected: isSelected,
                  onTap: () {
                    final current = List<String>.from(selectedGenres);
                    if (isSelected) {
                      current.remove(genre);
                    } else {
                      current.add(genre);
                    }
                    ref.read(selectedGenresProvider.notifier).state = current;
                  },
                );
              }).toList(),
            ),
            loading: () => const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Carregando...')),
              ],
            ),
            error: (_, __) => const Text('Erro ao carregar gêneros'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
    WidgetRef ref,
    MediaType? type,
    String label,
    bool isSelected,
  ) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.transparent,
          foregroundColor: isSelected ? Colors.black : Colors.white70,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          ref.read(selectedTypeProvider.notifier).state = type;
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
