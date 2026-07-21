import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';

class StreamingBadge extends StatelessWidget {
  final StreamingPlatform platform;
  final double size;
  final bool showName;

  const StreamingBadge({
    super.key,
    required this.platform,
    this.size = 28,
    this.showName = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: size,
        height: size,
        color: Colors.white.withOpacity(0.05),
        child: platform.logoUrl != null
            ? CachedNetworkImage(
                imageUrl: platform.logoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.white.withOpacity(0.05),
                ),
                errorWidget: (context, url, error) => Container(
                  alignment: Alignment.center,
                  color: Colors.grey[900],
                  child: Text(
                    platform.name.isNotEmpty ? platform.name[0] : 'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : Container(
                alignment: Alignment.center,
                color: Colors.grey[800],
                child: Text(
                  platform.name.isNotEmpty ? platform.name[0] : 'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );

    if (!showName) {
      return Tooltip(
        message: platform.name,
        child: logoWidget,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoWidget,
          const SizedBox(width: 6),
          Text(
            platform.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
