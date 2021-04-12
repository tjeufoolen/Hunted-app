import 'package:hunted_app/models/game.dart';
import 'package:hunted_app/services/dataservice.dart';

class GameDataService extends DataService<Game> {
  @override
  convert(Map<String, dynamic> json) => Game.fromJson(json);

  @override
  convertArray(Map<String, dynamic> json) {
    // TODO: implement convertArray
    throw UnimplementedError();
  }
}
