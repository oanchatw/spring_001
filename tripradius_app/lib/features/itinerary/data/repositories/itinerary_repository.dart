import '../../../../core/network/api_service.dart';
import '../models/route_model.dart';

class ItineraryRepository {
  final ApiService _api;
  ItineraryRepository(this._api);

  Future<List<RouteModel>> getRoutes() => _api.getRoutes();

  Future<RouteModel> createRoute(RouteModel route) =>
      _api.createRoute(route.toRequestBody());

  Future<void> deleteRoute(int id) => _api.deleteRoute(id);
}
