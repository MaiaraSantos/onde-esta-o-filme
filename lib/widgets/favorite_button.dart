import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final MediaItem item;
  final double size;

  const FavoriteButton({
    super.key,
    required this.item,
    this.size = 24,
  });

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    _controller.forward(from: 0.0);
    ref.read(watchlistProvider.notifier).toggleFavorite(widget.item);
    
    // Feedback visual rápido
    final watchlist = ref.read(watchlistProvider);
    final willBeFav = !watchlist.any((e) => e.id == widget.item.id);
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willBeFav
              ? 'Adicionado à lista "Quero Assistir": ${widget.item.title}'
              : 'Removido da lista "Quero Assistir": ${widget.item.title}',
          style: TextStyle(
            color: willBeFav ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: willBeFav ? AppTheme.primaryColor : Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider);
    final isFav = watchlist.any((e) => e.id == widget.item.id);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        iconSize: widget.size,
        onPressed: _onPressed,
        icon: Icon(
          isFav ? Icons.bookmark : Icons.bookmark_border,
          color: isFav ? AppTheme.primaryColor : Colors.white70,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.5),
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}
