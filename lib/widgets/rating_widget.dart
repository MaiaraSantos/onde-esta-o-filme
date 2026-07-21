import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double? ratingImdb;
  final double? ratingRottenTomatoes;
  final double ratingTmdb;

  const RatingWidget({
    super.key,
    this.ratingImdb,
    this.ratingRottenTomatoes,
    required this.ratingTmdb,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (ratingImdb != null)
          _buildRatingBadge(
            label: 'IMDb',
            value: ratingImdb!.toStringAsFixed(1),
            backgroundColor: const Color(0xFFF5C518),
            textColor: Colors.black,
          ),
        if (ratingRottenTomatoes != null)
          _buildRatingBadge(
            label: 'Rotten',
            value: '${ratingRottenTomatoes!.toInt()}%',
            backgroundColor: const Color(0xFFFA320A),
            textColor: Colors.white,
          ),
        _buildRatingBadge(
          label: 'TMDB',
          value: ratingTmdb.toStringAsFixed(1),
          backgroundColor: const Color(0xFF032541),
          textColor: const Color(0xFF01B4E4),
        ),
      ],
    );
  }

  Widget _buildRatingBadge({
    required String label,
    required String value,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
