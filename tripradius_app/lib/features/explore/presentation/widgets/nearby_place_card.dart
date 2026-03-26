import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/nearby_place_model.dart';

class NearbyPlaceCard extends StatelessWidget {
  final NearbyPlaceModel place;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const NearbyPlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool? openNow = place.openNow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3460).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ─────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: place.photoReference != null
                        ? Image.network(
                            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photo_reference=${place.photoReference}&key=YOUR_KEY',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _PlaceholderIcon(place: place),
                          )
                        : _PlaceholderIcon(place: place),
                  ),
                ),
                // Rating badge
                if (place.rating != null)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 9, color: AppColors.starYellow),
                          const SizedBox(width: 2),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Save button
                          GestureDetector(
                            onTap: onSave,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.outline),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _categoryIcon(place.displayCategory),
                            size: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.displayCategory,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          if (place.priceLevel != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('•',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.outline,
                                  )),
                            ),
                            Text(
                              place.priceLevel!,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Distance + Status
                  Row(
                    children: [
                      Icon(Icons.near_me_rounded,
                          size: 11, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 3),
                      Text(
                        place.vicinity?.split(',').first ?? 'Nearby',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (openNow != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('|',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              )),
                        ),
                        Text(
                          openNow ? 'Open Now' : 'Closing soon',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: openNow
                                ? AppColors.openGreen
                                : AppColors.closingSoon,
                          ),
                        ),
                      ],
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

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'urban park':
      case 'nature':
        return Icons.park_rounded;
      case 'museum':
      case 'art gallery':
        return Icons.museum_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final NearbyPlaceModel place;
  const _PlaceholderIcon({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.place_rounded,
          color: AppColors.primary.withOpacity(0.4),
          size: 32,
        ),
      ),
    );
  }
}
