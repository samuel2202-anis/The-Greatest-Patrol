import 'package:den/widgets/home.dart';
import 'package:den/widgets/login_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:den/theme.dart';

import 'login.dart';
//pdf:
  //printing:
  //google_fonts:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          appId: '1:1000661085166:android:4c9190eff8577c49e2fcff',
          messagingSenderId: '1000661085166',
          projectId: 'camp-645f3', apiKey: 'AIzaSyCHbqHrjFz6IJNSXSO_H-u9r5RUXmDLO_A')
  );

  runApp(MyApp());
}
Future<String?> getGroup() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('name');
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _init = Firebase.initializeApp();
    return MaterialApp(
      theme: ThemeData(primaryColor: secondColor,
          indicatorColor: thirdColor,
          //backgroundColor: secondColor,
          focusColor: thirdColor,
          //accentColor: secondColor
      ),
      title: 'The Greatest Patrol',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Future.wait([_init, getGroup()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            print("Error");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if(kIsWeb){
              return LoginWeb();
            }
            String? name = snapshot.data?[1] as String?;
            if (name != null && name.isNotEmpty) {
              return Home();
            } else {
              return Login();
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}



