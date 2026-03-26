import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../data/models/nearby_place_model.dart';
import '../cubit/explore_cubit.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/nearby_place_card.dart';
import '../../../places/presentation/cubit/places_cubit.dart';
import '../../../places/data/models/saved_place_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // San Francisco as default (before GPS)
  static const _defaultLocation = LatLng(37.7749, -122.4194);
  GoogleMapController? _mapController;
  int _selectedRadius = 5;
  String _viewMode = 'split'; // 'map' | 'split' | 'list'

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ExploreCubit>()
            ..searchNearby(location: _defaultLocation, radiusKm: _selectedRadius),
        ),
        BlocProvider(create: (_) => sl<PlacesCubit>()),
      ],
      child: Builder(builder: (context) => _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ExploreCubit, ExploreState>(
        builder: (context, state) {
          return Stack(
            children: [
              // ── Content Area ─────────────────────────────────
              _buildContentArea(context, state),

              // ── Top Overlay (Search + Filters) ───────────────
              _buildTopOverlay(context, state),

              // ── My Itinerary FAB ─────────────────────────────
              _buildItineraryFab(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, ExploreState state) {
    switch (_viewMode) {
      case 'map':
        return _MapView(
          location: state is ExploreLoaded ? state.currentLocation : _defaultLocation,
          places: state is ExploreLoaded ? state.places : [],
          radiusKm: _selectedRadius,
          onMapCreated: (c) => _mapController = c,
        );
      case 'list':
        return _buildListOnly(context, state);
      default: // split
        return Column(
          children: [
            // Map (top ~45%)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: _MapView(
                location: state is ExploreLoaded
                    ? state.currentLocation
                    : _defaultLocation,
                places: state is ExploreLoaded ? state.places : [],
                radiusKm: _selectedRadius,
                onMapCreated: (c) => _mapController = c,
              ),
            ),
            // List (bottom ~55%)
            Expanded(child: _buildNearbyList(context, state)),
          ],
        );
    }
  }

  Widget _buildTopOverlay(BuildContext context, ExploreState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search attractions...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<ExploreCubit>().searchNearby(
                                location: state is ExploreLoaded
                                    ? state.currentLocation
                                    : _defaultLocation,
                                keyword: value,
                              );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 0.75,
                    height: 24,
                    color: Theme.of(context).colorScheme.outline,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.mic_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Radius + Category filters row
            SizedBox(
              height: 32,
              child: Row(
                children: [
                  // Radius chip
                  GestureDetector(
                    onTap: () => _showRadiusPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            blurRadius: 0,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.radio_button_checked,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '$_selectedRadius km',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.white.withOpacity(0.5),
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                  ),

                  // Category filters (scrollable)
                  Expanded(
                    child: CategoryFilterBar(
                      selected: state is ExploreLoaded
                          ? state.activeCategory
                          : null,
                      onSelected: (cat) =>
                          context.read<ExploreCubit>().setCategory(cat),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyList(BuildContext context, ExploreState state) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.5),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Nearby Attractions',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                if (state is ExploreLoaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${state.places.length}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'Sort by: Distance',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // View mode toggle
          _ViewModeToggle(
            current: _viewMode,
            onChanged: (mode) => setState(() => _viewMode = mode),
          ),

          const SizedBox(height: 4),

          // List
          Expanded(child: _buildPlacesList(context, state)),
        ],
      ),
    );
  }

  Widget _buildListOnly(BuildContext context, ExploreState state) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 160), // space for overlaid top bar
          Expanded(child: _buildNearbyList(context, state)),
        ],
      ),
    );
  }

  Widget _buildPlacesList(BuildContext context, ExploreState state) {
    if (state is ExploreLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is ExploreError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Could not load places\n${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<ExploreCubit>().refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is ExploreLoaded) {
      if (state.places.isEmpty) {
        return const Center(
          child: Text(
            'No attractions found nearby.\nTry adjusting radius or category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: state.places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final place = state.places[i];
          return NearbyPlaceCard(
            place: place,
            onTap: () => context.push(
              '/places/${place.placeId}',
              extra: {
                'name': place.name,
                'address': place.vicinity,
                'lat': place.lat,
                'lng': place.lng,
                'rating': place.rating,
                'openNow': place.openNow,
                'category': place.displayCategory,
              },
            ),
            onSave: () => _savePlace(context, place),
          );
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildItineraryFab(BuildContext context) {
    return Positioned(
      bottom: 96,
      right: 20,
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.itinerary),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'My Itinerary',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRadiusPicker(BuildContext context) {
    final cubit = context.read<ExploreCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Radius',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            for (final km in [1, 2, 5, 10, 20])
              ListTile(
                title: Text('$km km'),
                leading: Radio<int>(
                  value: km,
                  groupValue: _selectedRadius,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _selectedRadius = v!);
                    cubit.setRadius(v!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() => _selectedRadius = km);
                  cubit.setRadius(km);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _savePlace(BuildContext context, NearbyPlaceModel place) {
    final placesCubit = context.read<PlacesCubit>();
    placesCubit.savePlace(SavedPlaceModel(
      placeId: place.placeId,
      name: place.name,
      address: place.vicinity,
      latitude: place.lat,
      longitude: place.lng,
      category: place.displayCategory.toLowerCase(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.name} saved!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Map View ──────────────────────────────────────────────────────────────────
class _MapView extends StatelessWidget {
  final LatLng location;
  final List<NearbyPlaceModel> places;
  final int radiusKm;
  final void Function(GoogleMapController) onMapCreated;

  const _MapView({
    required this.location,
    required this.places,
    required this.radiusKm,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final markers = places
        .map(
          (p) => Marker(
            markerId: MarkerId(p.placeId),
            position: LatLng(p.lat, p.lng),
            infoWindow: InfoWindow(title: p.name, snippet: p.displayCategory),
          ),
        )
        .toSet();

    // User location marker
    markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: location, zoom: 13),
      markers: markers,
      circles: {
        Circle(
          circleId: const CircleId('radius'),
          center: location,
          radius: radiusKm * 1000,
          fillColor: AppColors.primary.withOpacity(0.08),
          strokeColor: AppColors.primary.withOpacity(0.3),
          strokeWidth: 2,
        ),
      },
      onMapCreated: onMapCreated,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      mapType: MapType.normal,
    );
  }
}

// ── View Mode Toggle ──────────────────────────────────────────────────────────
class _ViewModeToggle extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _ViewModeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.85),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleButton('map', 'Map', context),
            _toggleButton('split', 'Split', context),
            _toggleButton('list', 'List', context),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String mode, String label, BuildContext context) {
    final isSelected = current == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
