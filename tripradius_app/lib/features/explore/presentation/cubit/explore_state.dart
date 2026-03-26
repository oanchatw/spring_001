part of 'explore_cubit.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();
  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}
class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<NearbyPlaceModel> places;
  final LatLng currentLocation;
  final int radiusKm;
  final String? activeCategory;

  const ExploreLoaded({
    required this.places,
    required this.currentLocation,
    required this.radiusKm,
    this.activeCategory,
  });

  @override
  List<Object?> get props => [places, currentLocation, radiusKm, activeCategory];
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError(this.message);
  @override
  List<Object?> get props => [message];
}
