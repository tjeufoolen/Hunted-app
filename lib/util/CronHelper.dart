import 'package:cron/cron.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:location/location.dart';

class CronHelper {
  static final CronHelper _instance = CronHelper._internal();
  Location _location = new Location();
  SocketService _socketService = new SocketService();
  Cron locationSentCronJob;

  void initializeCron(Player loggedInPlayer) {
    locationSentCronJob = new Cron();
    locationSentCronJob.schedule(new Schedule.parse('*/30 * * * * *'),
        () async {
      _location.getLocation().then((newLocation) {
        var message = {
          "id": loggedInPlayer.id,
          "gameId": loggedInPlayer.game.id,
          "latitude": newLocation.latitude,
          "longitude": newLocation.longitude
        };
        _socketService.emitData('send_location', message);
      });
    });
  }

  factory CronHelper() {
    return _instance;
  }

  CronHelper._internal();
}
