import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hunted_app/screens/login/loginArguments.dart';
import 'package:uni_links/uni_links.dart';
import 'package:hunted_app/routes/Routes.dart';

bool _initialUriIsHandled = false;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = getUriLinksStream().listen((Uri uri) {
        if (!mounted) return;
        final code = extractCodeFromUri(uri);
        if (code == null) return;

        goToLoginWithCode(code);
      }, onError: (Object err) {
        if (!mounted) return;
        displayGlobalInfoMessage(
            "Fout melding!", "Oh nee, er iets iets fout gegaan: " + err);
      });
    }
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri != null) {
          final code = extractCodeFromUri(uri);
          if (code == null) return;
          goToLoginWithCode(code);
        }
        if (!mounted) return;
      } on PlatformException {} on FormatException {
        if (!mounted) return;
        displayGlobalInfoMessage(
            "Foute URL", "De opgegeven URL is helaas niet juist.");
      }
    }
  }

  void goToLoginWithCode(String code) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState
          .pushReplacementNamed(Routes.Login, arguments: LoginArguments(code));
    });
  }

  String extractCodeFromUri(Uri uri) => uri.queryParameters['code'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hunted',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: Routes.Login,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: Routes.getRoutes());
  }

  void displayGlobalInfoMessage(String title, String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    });
  }
}
