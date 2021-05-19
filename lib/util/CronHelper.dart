import 'package:cron/cron.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:location/location.dart';

class CronHelper {
  Location _location = new Location();
  SocketService _socketService = new SocketService();

  Cron initializeCron(Player loggedInPlayer) {
    Cron cron = new Cron();
    cron.schedule(new Schedule.parse('*/30 * * * * *'), () async {
      _location.getLocation().then((newLocation) {
        var message = {
          "id": loggedInPlayer.id,
          "latitude": newLocation.latitude,
          "longitude": newLocation.longitude
        };
        _socketService.emitData('send_location', message);
      });
    });
    return cron;
  }
}
