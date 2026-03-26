import '../../../../core/network/api_service.dart';
import '../models/saved_place_model.dart';

class PlacesRepository {
  final ApiService _api;
  PlacesRepository(this._api);

  Future<List<SavedPlaceModel>> getPlaces({String? category}) =>
      _api.getPlaces(category: category);

  Future<SavedPlaceModel> createPlace(SavedPlaceModel place) =>
      _api.createPlace(place.toRequestBody());

  Future<SavedPlaceModel> updatePlace(int id, SavedPlaceModel place) =>
      _api.updatePlace(id, place.toRequestBody());

  Future<void> deletePlace(int id) => _api.deletePlace(id);
}
