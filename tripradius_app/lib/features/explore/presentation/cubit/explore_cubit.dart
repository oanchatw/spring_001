import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/nearby_place_model.dart';
import '../../data/repositories/explore_repository.dart';

part 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final ExploreRepository _repository;

  ExploreCubit(this._repository) : super(ExploreInitial());

  int _radiusKm = 5;
  String? _activeCategory;
  String? _keyword;
  LatLng? _currentLocation;

  int get radiusKm => _radiusKm;
  String? get activeCategory => _activeCategory;

  void setLocation(LatLng location) {
    _currentLocation = location;
  }

  Future<void> searchNearby({
    required LatLng location,
    int? radiusKm,
    String? category,
    String? keyword,
  }) async {
    _currentLocation = location;
    if (radiusKm != null) _radiusKm = radiusKm;
    _activeCategory = category;
    _keyword = keyword;

    emit(ExploreLoading());
    try {
      final typeMap = {
        'food': 'restaurant',
        'nature': 'park',
        'museum': 'museum',
        'hotel': 'lodging',
        'attraction': 'tourist_attraction',
      };
      final googleType = category != null
          ? typeMap[category.toLowerCase()]
          : null;

      final places = await _repository.searchNearby(
        lat: location.latitude,
        lng: location.longitude,
        radius: _radiusKm * 1000,
        type: googleType,
        keyword: keyword,
      );
      emit(ExploreLoaded(
        places: places,
        currentLocation: location,
        radiusKm: _radiusKm,
        activeCategory: _activeCategory,
      ));
    } catch (e) {
      emit(ExploreError(e.toString()));
    }
  }

  Future<void> refresh() async {
    if (_currentLocation == null) return;
    await searchNearby(
      location: _currentLocation!,
      radiusKm: _radiusKm,
      category: _activeCategory,
      keyword: _keyword,
    );
  }

  void setRadius(int km) {
    _radiusKm = km;
    refresh();
  }

  void setCategory(String? category) {
    _activeCategory = category == _activeCategory ? null : category;
    refresh();
  }
}
