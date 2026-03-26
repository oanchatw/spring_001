import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saved_place_model.g.dart';

@JsonSerializable()
class SavedPlaceModel extends Equatable {
  final int? id;
  final String? placeId;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? note;
  // restaurant / attraction / hotel / other
  final String? category;
  final String? createdAt;

  const SavedPlaceModel({
    this.id,
    this.placeId,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.note,
    this.category,
    this.createdAt,
  });

  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$SavedPlaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$SavedPlaceModelToJson(this);

  Map<String, dynamic> toRequestBody() => {
        if (placeId != null) 'placeId': placeId,
        'name': name,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (note != null) 'note': note,
        if (category != null) 'category': category,
      };

  @override
  List<Object?> get props =>
      [id, placeId, name, address, latitude, longitude, note, category];
}
