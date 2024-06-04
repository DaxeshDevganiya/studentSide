import 'dart:async';

import 'package:assignment_student/EmailPage.dart';
import 'package:assignment_student/firebase_options.dart';
import 'package:assignment_student/local_notification_service.dart';
import 'package:assignment_student/login.dart';
import 'package:assignment_student/student/Homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print("background here");

  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();

  // final fcmToken = await FirebaseMessaging.instance.getToken();

  // print("FCM TOken" + fcmToken.toString());
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Stripe.publishableKey =
      "pk_test_51OyfljGQ4hnFke5naCUJhUXTjEGCsmodhEk3qhAlJefkmKc5AoIw3bLBePR7K7rKHFdE32RwQpp5zyj5x7ZgIBEa00qzSZxqj2";
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> getDeviceTokenToSendNotification() async {
    final _fcm = await FirebaseMessaging.instance.getToken();
    final token = await _fcm.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString("fcmToken", token.toString());
    // print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    // print("heyyyyytoken" + FirebaseMessaging.instance.getToken().toString());
    print(_fcm);
  }

  locationChecker() async {
    if (await Permission.location.serviceStatus.isEnabled) {
    } else {}
  }

  Future<void> checkAuthentication() async {
    final _fcm = await FirebaseMessaging.instance.getToken();
    final token = await _fcm.toString();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isLogin');
    // await prefs.setString("fcmToken", token.toString());
    if (isAuthenticated == true) {
      // If the user is already authenticated, navigate to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Email()));
    }
  }

  @override
  void initState() async {
    final _fcm = await FirebaseMessaging.instance.getToken();
    final token = await _fcm.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmToken", token.toString());

    checkAuthentication();
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
    getDeviceTokenToSendNotification();
    Timer(
        Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context,
            PageTransition(
                child: Email(), type: PageTransitionType.leftToRight)));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff60467A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(color: Color(0xff60467A)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 90),
                      Text("Assignment System",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                          )),
                      Image.asset(
                        "assets/images/splash2.png",
                        height: screenHeight * 0.8,
                        width: screenWidth * 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
