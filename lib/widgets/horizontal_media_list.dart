import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
import 'movie_card.dart';

class HorizontalMediaList extends StatefulWidget {
  final String title;
  final List<MediaItem> items;
  final double cardWidth;
  final double listHeight;

  const HorizontalMediaList({
    super.key,
    required this.title,
    required this.items,
    this.cardWidth = 170.0,
    this.listHeight = 350.0,
  });

  @override
  State<HorizontalMediaList> createState() => _HorizontalMediaListState();
}

class _HorizontalMediaListState extends State<HorizontalMediaList> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowsVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrowsVisibility();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrowsVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrowsVisibility() {
    if (!_scrollController.hasClients) return;

    final canScrollLeft = _scrollController.position.pixels > 0;
    final canScrollRight = _scrollController.position.pixels < _scrollController.position.maxScrollExtent;

    if (canScrollLeft != _showLeftArrow) {
      setState(() => _showLeftArrow = canScrollLeft);
    }
    if (canScrollRight != _showRightArrow) {
      setState(() => _showRightArrow = canScrollRight);
    }
  }

  void _scrollList(double direction) {
    if (!_scrollController.hasClients) return;
    final currentPos = _scrollController.position.pixels;
    // Rola equivalente a cerca de 3 a 4 cards por vez
    final scrollAmount = widget.cardWidth * 3.5;
    final targetPos = currentPos + (scrollAmount * direction);

    _scrollController.animateTo(
      targetPos.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: widget.listHeight,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: widget.cardWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: MovieCard(item: widget.items[index]),
                  );
                },
              ),
              // Seta Esquerda
              if (_showLeftArrow)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _scrollList(-1),
                    alignment: Alignment.centerLeft,
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              // Seta Direita
              if (_showRightArrow)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _scrollList(1),
                    alignment: Alignment.centerRight,
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required Alignment alignment,
    required Gradient gradient,
  }) {
    return Container(
      width: 60,
      decoration: BoxDecoration(gradient: gradient),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurfaceCard.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white, size: 32),
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
