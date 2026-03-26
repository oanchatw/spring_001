// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedPlaceModel _$SavedPlaceModelFromJson(Map<String, dynamic> json) =>
    SavedPlaceModel(
      id: (json['id'] as num?)?.toInt(),
      placeId: json['placeId'] as String?,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      note: json['note'] as String?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$SavedPlaceModelToJson(SavedPlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'placeId': instance.placeId,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'note': instance.note,
      'category': instance.category,
      'createdAt': instance.createdAt,
    };
