import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/saved_place_model.dart';
import '../../data/repositories/places_repository.dart';

part 'places_state.dart';

class PlacesCubit extends Cubit<PlacesState> {
  final PlacesRepository _repository;
  PlacesCubit(this._repository) : super(PlacesInitial());

  Future<void> loadPlaces({String? category}) async {
    emit(PlacesLoading());
    try {
      final places = await _repository.getPlaces(category: category);
      emit(PlacesLoaded(places));
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }

  Future<void> savePlace(SavedPlaceModel place) async {
    try {
      await _repository.createPlace(place);
      await loadPlaces();
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }

  Future<void> updatePlace(int id, SavedPlaceModel place) async {
    try {
      await _repository.updatePlace(id, place);
      await loadPlaces();
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }

  Future<void> deletePlace(int id) async {
    try {
      await _repository.deletePlace(id);
      if (state is PlacesLoaded) {
        final current = (state as PlacesLoaded).places;
        emit(PlacesLoaded(current.where((p) => p.id != id).toList()));
      }
    } catch (e) {
      emit(PlacesError(e.toString()));
    }
  }
}
