import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/GameLocation.dart';
import 'package:hunted_app/models/LocationTypeEnum.dart';
import 'package:hunted_app/models/Markers/PoliceMarker.dart';
import 'package:hunted_app/models/Markers/PoliceStationMarker.dart';
import 'package:hunted_app/models/Markers/ThiefMarker.dart';
import 'package:hunted_app/models/Markers/TreasureMarker.dart';

class MarkerFactory {
  static final MarkerFactory _instance = MarkerFactory._internal();

  int _createCounter = 0;

  Future<Marker> create(LocationType locationType, LatLng location, int id) async {
    var futureMarker;

    switch (locationType) {
      case LocationType.POLICE_STATION:
        futureMarker = PoliceStationMarker(newMarkerId(), location);
        break;
      case LocationType.TREASURE:
        futureMarker = TreasureMarker(newMarkerId(), location, id);
        break;
      case LocationType.POLICE:
        futureMarker = PoliceMarker(newMarkerId(), location);
        break;
      case LocationType.THIEF:
        futureMarker = ThiefMarker(newMarkerId(), location);
        break;
      default:
        return null;
    }

    return await futureMarker.getGoogleMarker().then((value) => value);
  }

  Future<List<Marker>> createAll(List<GameLocation> locations) async {
    return Stream.fromIterable(locations)
        .asyncMap((e) => this.create(
            e.locationType, LatLng(e.location.latitude, e.location.longitude), e.id))
        .toList();
  }

  MarkerId newMarkerId() => MarkerId((_createCounter++).toString());

  factory MarkerFactory() {
    return _instance;
  }

  MarkerFactory._internal();
}
