import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/saved_place_model.dart';
import '../cubit/places_cubit.dart';

class PlaceDetailsPage extends StatelessWidget {
  final String placeId;
  final Map<String, dynamic>? extra;

  const PlaceDetailsPage({
    super.key,
    required this.placeId,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlacesCubit>(),
      child: _PlaceDetailsView(placeId: placeId, extra: extra),
    );
  }
}

class _PlaceDetailsView extends StatelessWidget {
  final String placeId;
  final Map<String, dynamic>? extra;

  const _PlaceDetailsView({required this.placeId, this.extra});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = extra?['name'] as String? ?? 'Place Details';
    final address = extra?['address'] as String?;
    final rating = extra?['rating'] as double?;
    final openNow = extra?['openNow'] as bool?;
    final category = extra?['category'] as String? ?? 'Place';
    final lat = extra?['lat'] as double?;
    final lng = extra?['lng'] as double?;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded,
                      color: Colors.white),
                  onPressed: () => _savePlace(context, name, address, lat, lng, category),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A4D8E), Color(0xFF0F3460)],
                      ),
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Rating + Distance + Status
                  Row(
                    children: [
                      if (rating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.starYellow),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (address != null) ...[
                        Icon(Icons.near_me_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            address.split(',').first,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (openNow != null)
                        Text(
                          openNow ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: openNow
                                ? AppColors.openGreen
                                : AppColors.closingSoon,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.language_rounded,
                        label: 'Website',
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () {},
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.more_horiz_rounded,
                        label: 'More',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A must-visit destination with fascinating history and stunning views. '
                    'Perfect for travellers looking to immerse themselves in local culture. '
                    'Highly recommended for all ages.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _savePlace(
                              context, name, address, lat, lng, category),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add to Itinerary'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.navigation_rounded, size: 18),
                          label: const Text('Navigate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Address
                  if (address != null) ...[
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      text: openNow == true ? 'Open Now' : 'Hours unavailable',
                      subText: openNow == true
                          ? 'Pedestrians: Mon – Sun'
                          : null,
                      textColor: openNow == true
                          ? AppColors.openGreen
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      text: address,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePlace(
    BuildContext context,
    String name,
    String? address,
    double? lat,
    double? lng,
    String category,
  ) {
    context.read<PlacesCubit>().savePlace(
          SavedPlaceModel(
            placeId: placeId,
            name: name,
            address: address,
            latitude: lat,
            longitude: lng,
            category: category.toLowerCase(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name saved!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subText;
  final Color? textColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.subText,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor ?? theme.colorScheme.onSurface,
                ),
              ),
              if (subText != null)
                Text(
                  subText!,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
