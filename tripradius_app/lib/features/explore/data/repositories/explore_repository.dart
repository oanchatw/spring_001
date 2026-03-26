import '../../../../core/network/api_service.dart';
import '../models/nearby_place_model.dart';

class ExploreRepository {
  final ApiService _api;
  ExploreRepository(this._api);

  Future<List<NearbyPlaceModel>> searchNearby({
    required double lat,
    required double lng,
    int radius = 1000,
    String? type,
    String? keyword,
  }) async {
    final response = await _api.searchNearby(
      lat: lat,
      lng: lng,
      radius: radius,
      type: type,
      keyword: keyword,
    );
    final results = response['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => NearbyPlaceModel.fromGoogleJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) =>
      _api.getPlaceDetails(placeId);

  Future<Map<String, dynamic>> getDirections({
    required String origin,
    required String destination,
    String? waypoints,
    String mode = 'driving',
  }) =>
      _api.getDirections(
        origin: origin,
        destination: destination,
        waypoints: waypoints,
        mode: mode,
      );

  Future<Map<String, dynamic>> geocode(String address) =>
      _api.geocode(address);
}
