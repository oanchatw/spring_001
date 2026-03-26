import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../constants/api_constants.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/places/data/models/saved_place_model.dart';
import '../../features/itinerary/data/models/route_model.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: '')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // ── Auth ────────────────────────────────────────────────────
  @GET(ApiConstants.me)
  Future<UserModel> getMe();

  // ── Places ──────────────────────────────────────────────────
  @GET(ApiConstants.places)
  Future<List<SavedPlaceModel>> getPlaces({
    @Query('category') String? category,
  });

  @POST(ApiConstants.places)
  Future<SavedPlaceModel> createPlace(@Body() Map<String, dynamic> body);

  @PUT('/api/places/{id}')
  Future<SavedPlaceModel> updatePlace(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/places/{id}')
  Future<Map<String, dynamic>> deletePlace(@Path('id') int id);

  // ── Routes ──────────────────────────────────────────────────
  @GET(ApiConstants.routes)
  Future<List<RouteModel>> getRoutes();

  @POST(ApiConstants.routes)
  Future<RouteModel> createRoute(@Body() Map<String, dynamic> body);

  @DELETE('/api/routes/{id}')
  Future<Map<String, dynamic>> deleteRoute(@Path('id') int id);

  // ── Maps ────────────────────────────────────────────────────
  @GET(ApiConstants.mapsNearby)
  Future<Map<String, dynamic>> searchNearby({
    @Query('lat') required double lat,
    @Query('lng') required double lng,
    @Query('radius') int radius = 1000,
    @Query('type') String? type,
    @Query('keyword') String? keyword,
  });

  @GET(ApiConstants.mapsDirections)
  Future<Map<String, dynamic>> getDirections({
    @Query('origin') required String origin,
    @Query('destination') required String destination,
    @Query('waypoints') String? waypoints,
    @Query('mode') String mode = 'driving',
  });

  @GET('/api/maps/place/{placeId}')
  Future<Map<String, dynamic>> getPlaceDetails(
    @Path('placeId') String placeId,
  );

  @GET(ApiConstants.mapsGeocode)
  Future<Map<String, dynamic>> geocode(@Query('address') String address);
}
