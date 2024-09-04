import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:den/widgets/home.dart';
import 'package:den/widgets/login_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:den/theme.dart';

import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          appId: '1:1000661085166:android:4c9190eff8577c49e2fcff',
          messagingSenderId: '1000661085166',
          projectId: 'camp-645f3', apiKey: 'AIzaSyCHbqHrjFz6IJNSXSO_H-u9r5RUXmDLO_A')
  );
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      // Handle the message
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle the message
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle the message
  });
  // AwesomeNotifications().initialize(
  //   'resource://drawable/game',
  //   [
  //     NotificationChannel(
  //         channelKey: 'basic_channel',
  //         channelName: 'Basic notifications',
  //         channelDescription: 'Notification channel for basic tests',
  //         ledColor: Colors.white,
  //         playSound: false,
  //         // defaultRingtoneType: DefaultRingtoneType.Notification,
  //         soundSource: 'resource://raw/den')
  //   ],
  // );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel', // Make sure this matches the channel key used in AwesomeNotifications().initialize()
        title: message.data['title'] ?? '',
        body: message.data['body'] ?? '',
        customSound:  'resource://raw/den',
        wakeUpScreen: true,
        fullScreenIntent: true
    ),
  );
}