import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/route_model.dart';
import '../cubit/itinerary_cubit.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ItineraryCubit>()..loadRoutes(),
      child: const _ItineraryView(),
    );
  }
}

class _ItineraryView extends StatelessWidget {
  const _ItineraryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ItineraryCubit, ItineraryState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── Map Header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: theme.colorScheme.surface,
                title: const Text('Trips'),
                centerTitle: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(48.8566, 2.3522), // Paris default
                      zoom: 11,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    markers: state is ItineraryLoaded
                        ? _buildMarkers(state.routes)
                        : {},
                  ),
                ),
              ),

              // ── Routes list ──────────────────────────────────
              if (state is ItineraryLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (state is ItineraryLoaded && state.routes.isEmpty)
                SliverFillRemaining(
                  child: _EmptyItinerary(
                    onAdd: () => _showAddRouteDialog(context),
                  ),
                )
              else if (state is ItineraryLoaded) ...[
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Itinerary',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${state.routes.length} route${state.routes.length != 1 ? 's' : ''} saved',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                color:
                                    theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                '3h 15m',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Route Cards
                SliverList.separated(
                  itemCount: state.routes.length,
                  separatorBuilder: (_, __) => const SizedBox(),
                  itemBuilder: (context, i) {
                    final route = state.routes[i];
                    return _RouteCard(
                      index: i + 1,
                      route: route,
                      onDelete: () {
                        if (route.id != null) {
                          context.read<ItineraryCubit>().deleteRoute(route.id!);
                        }
                      },
                    );
                  },
                ),

                // Bottom CTA
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddRouteDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('Add Place'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: const Text('Start Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                        textStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (state is ItineraryError)
                SliverFillRemaining(
                  child: Center(
                    child: Text('Error: ${state.message}'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRouteDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Set<Marker> _buildMarkers(List<RouteModel> routes) {
    return routes.asMap().entries.map((entry) {
      return Marker(
        markerId: MarkerId('route_${entry.key}'),
        position: const LatLng(48.8566, 2.3522),
        infoWindow: InfoWindow(title: entry.value.name ?? entry.value.origin),
      );
    }).toSet();
  }

  void _showAddRouteDialog(BuildContext context) {
    final cubit = context.read<ItineraryCubit>();
    final nameCtrl = TextEditingController();
    final originCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    String mode = 'DRIVING';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Route',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Trip Name (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: originCtrl,
                decoration: const InputDecoration(
                  labelText: 'Origin *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trip_origin_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destCtrl,
                decoration: const InputDecoration(
                  labelText: 'Destination *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),
              const SizedBox(height: 12),
              // Travel mode
              Row(
                children: [
                  const Text(
                    'Mode: ',
                    style: TextStyle(fontFamily: 'Manrope'),
                  ),
                  for (final m in ['DRIVING', 'WALKING', 'BICYCLING', 'TRANSIT'])
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(m.substring(0, 1)),
                        selected: mode == m,
                        onSelected: (_) => setModalState(() => mode = m),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: mode == m ? Colors.white : null,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (originCtrl.text.isNotEmpty &&
                        destCtrl.text.isNotEmpty) {
                      cubit.createRoute(RouteModel(
                        name: nameCtrl.text.isEmpty ? null : nameCtrl.text,
                        origin: originCtrl.text,
                        destination: destCtrl.text,
                        travelMode: mode,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final int index;
  final RouteModel route;
  final VoidCallback onDelete;

  const _RouteCard({
    required this.index,
    required this.route,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index bubble
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (index > 0)
                Container(
                  width: 2,
                  height: 20,
                  color: AppColors.primary.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _modeIcon(route.travelMode),
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name ?? route.origin,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(_modeIcon(route.travelMode),
                                size: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Text(
                              '${route.travelMode} · → ${route.destination}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (route.waypoints != null)
                          Text(
                            route.waypoints!,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Delete
                  IconButton(
                    icon: Icon(Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    onPressed: () => _showOptions(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _modeIcon(String mode) {
    switch (mode.toUpperCase()) {
      case 'WALKING':
        return Icons.directions_walk_rounded;
      case 'BICYCLING':
        return Icons.directions_bike_rounded;
      case 'TRANSIT':
        return Icons.directions_transit_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.accent),
              title: const Text(
                'Delete Route',
                style: TextStyle(color: AppColors.accent, fontFamily: 'Manrope'),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyItinerary extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyItinerary({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_outlined, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No routes planned yet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first route to start\nplanning your adventure.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create Route'),
          ),
        ],
      ),
    );
  }
}
