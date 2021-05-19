import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hunted_app/routes/Routes.dart';
import 'package:flutter_config/flutter_config.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hunted',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: Routes.Login,
        debugShowCheckedModeBanner: false,
        routes: Routes.getRoutes());
  }
}
