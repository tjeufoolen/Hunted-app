import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/GameLocation.dart';
import 'package:hunted_app/models/LocationTypeEnum.dart';
import 'package:hunted_app/models/Markers/CustomMarker.dart';
import 'package:hunted_app/models/Markers/PoliceStationMarker.dart';
import 'package:hunted_app/models/Markers/TreasureMarker.dart';

class MarkerFactory {
  static final MarkerFactory _instance = MarkerFactory._internal();

  int _createCounter = 0;

  Future<CustomMarker> create(
      LocationType locationType, LatLng location) async {
    CustomMarker returnMarker;

    switch (locationType) {
      case LocationType.POLICE_STATION:
        {
          final icon = await PoliceStationMarker.getIcon();
          _createCounter++;
          returnMarker = PoliceStationMarker(
              MarkerId(_createCounter.toString()), location, icon);
        }
        break;
      case LocationType.TREASURE:
        {
          final icon = await TreasureMarker.getIcon();
          _createCounter++;
          returnMarker = TreasureMarker(
              MarkerId(_createCounter.toString()), location, icon);
        }
        break;
      default:
        returnMarker = null;
    }

    return returnMarker;
  }

  Future<List<CustomMarker>> createAll(List<GameLocation> locations) async {
    // List<CustomMarker> list = [];

    // await Future.forEach(locations, (e) async {
    //   list.add(await this.create(
    //       e.locationType, LatLng(e.location.latitude, e.location.longitude)));
    // });

    return Stream.fromIterable(locations)
        .asyncMap((e) => this.create(
            e.locationType, LatLng(e.location.latitude, e.location.longitude)))
        .toList();

    // return list;
  }

  factory MarkerFactory() {
    return _instance;
  }
  MarkerFactory._internal() {}
}
