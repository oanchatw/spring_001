class ApiConstants {
  // Change this to your Spring Boot server address
  // For Android emulator: 10.0.2.2 maps to host's localhost
  // For physical device: use your machine's local IP e.g. 192.168.x.x
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Auth
  static const String me = '/api/auth/me';
  static const String oauthGoogle = '/oauth2/authorization/google';
  static const String logout = '/logout';

  // Places
  static const String places = '/api/places';
  static String placeById(int id) => '/api/places/$id';

  // Routes
  static const String routes = '/api/routes';
  static String routeById(int id) => '/api/routes/$id';

  // Maps
  static const String mapsNearby = '/api/maps/nearby';
  static const String mapsDirections = '/api/maps/directions';
  static String mapsPlace(String placeId) => '/api/maps/place/$placeId';
  static const String mapsGeocode = '/api/maps/geocode';
}
