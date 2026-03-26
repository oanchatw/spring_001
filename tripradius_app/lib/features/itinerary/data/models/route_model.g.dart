// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      waypoints: json['waypoints'] as String?,
      travelMode: json['travelMode'] as String? ?? 'DRIVING',
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'origin': instance.origin,
      'destination': instance.destination,
      'waypoints': instance.waypoints,
      'travelMode': instance.travelMode,
      'createdAt': instance.createdAt,
    };
