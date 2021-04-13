import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

import 'package:hunted_app/screens/login.dart';

Future main() async {
  await DotEnv.load(fileName: ".env");
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
        initialRoute: "/login",
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          "/login": (BuildContext context) => new Login()
        });
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   Future<Player> prototype;

//   @override
//   void initState() {
//     super.initState();
//     prototype = AuthDataService()
//         .joinGame('67477-15e87-46818-a097e-aba3c-2aab4-02c53-1f2aa');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             FutureBuilder<Player>(
//                 future: prototype,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return Column(children: [
//                       Text(snapshot.data.id.toString()),
//                       Text(snapshot.data.code),
//                       Text(snapshot.data.playerRole.toString()),
//                     ]);
//                   } else if (snapshot.hasError) {
//                     return Text("${snapshot.error}");
//                   } else {
//                     return Text("No data and no error!?");
//                   }
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }
