import 'package:hunted_app/models/Location.dart';
import 'LocationTypeEnum.dart';

class GameLocation {
  final int id;
  final String name;
  final Location location;
  final LocationType locationType;

  GameLocation({this.id, this.name, this.location, this.locationType});

  factory GameLocation.fromJson(Map<String, dynamic> json) {
    return GameLocation(
      id: json['id'],
      name: json['name'],
      location: Location.fromJson(json['location']),
      locationType: LocationType.values[json['type']],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location.toJson(),
        'type': locationType.index
      };
}
