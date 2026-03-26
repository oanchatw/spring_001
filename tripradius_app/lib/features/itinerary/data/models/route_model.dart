import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_model.g.dart';

@JsonSerializable()
class RouteModel extends Equatable {
  final int? id;
  final String? name;
  final String origin;
  final String destination;
  final String? waypoints;
  @JsonKey(defaultValue: 'DRIVING')
  final String travelMode;
  final String? createdAt;

  const RouteModel({
    this.id,
    this.name,
    required this.origin,
    required this.destination,
    this.waypoints,
    this.travelMode = 'DRIVING',
    this.createdAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        'origin': origin,
        'destination': destination,
        if (waypoints != null) 'waypoints': waypoints,
        'travelMode': travelMode,
      };

  @override
  List<Object?> get props => [id, name, origin, destination, waypoints, travelMode];
}
