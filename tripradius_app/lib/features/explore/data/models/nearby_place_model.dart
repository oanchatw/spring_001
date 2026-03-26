import 'package:equatable/equatable.dart';

/// Parsed from Google Places API response via Spring's /api/maps/nearby
class NearbyPlaceModel extends Equatable {
  final String placeId;
  final String name;
  final String? vicinity;
  final double? rating;
  final int? userRatingsTotal;
  final String? icon;
  final List<String> types;
  final bool? openNow;
  final String? photoReference;
  final double lat;
  final double lng;
  final String? priceLevel;

  const NearbyPlaceModel({
    required this.placeId,
    required this.name,
    this.vicinity,
    this.rating,
    this.userRatingsTotal,
    this.icon,
    this.types = const [],
    this.openNow,
    this.photoReference,
    required this.lat,
    required this.lng,
    this.priceLevel,
  });

  factory NearbyPlaceModel.fromGoogleJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final openingHours = json['opening_hours'] as Map<String, dynamic>?;
    final photos = json['photos'] as List<dynamic>?;
    final priceLevelInt = json['price_level'] as int?;

    String? priceLevelStr;
    if (priceLevelInt != null) {
      priceLevelStr = '\$' * priceLevelInt;
    }

    return NearbyPlaceModel(
      placeId: json['place_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      vicinity: json['vicinity'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      icon: json['icon'] as String?,
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? [],
      openNow: openingHours?['open_now'] as bool?,
      photoReference: photos?.isNotEmpty == true
          ? photos!.first['photo_reference'] as String?
          : null,
      lat: (location['lat'] as num?)?.toDouble() ?? 0,
      lng: (location['lng'] as num?)?.toDouble() ?? 0,
      priceLevel: priceLevelStr,
    );
  }

  String get displayCategory {
    if (types.contains('restaurant') || types.contains('food')) return 'Food';
    if (types.contains('museum')) return 'Museum';
    if (types.contains('park')) return 'Urban Park';
    if (types.contains('lodging')) return 'Hotel';
    if (types.contains('tourist_attraction')) return 'Attraction';
    if (types.contains('art_gallery')) return 'Art Gallery';
    if (types.contains('store') || types.contains('shopping_mall')) return 'Shopping';
    return types.isNotEmpty ? types.first.replaceAll('_', ' ') : 'Place';
  }

  @override
  List<Object?> get props => [placeId, name, lat, lng];
}
