import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whomii/Login/GoogleLogin.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:whomii/Menu/WhoiiMennu.dart';
import 'package:whomii/firebase_options.dart';

void main() => runApp(MyApp());

late final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

var prefsLogin;

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    Future.delayed(const Duration(seconds: 5), () async {
      prefsLogin = await SharedPreferences.getInstance();
      // set value
      if (_auth.currentUser?.email != null) {
        print(_auth.currentUser?.email);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return WhoiiMenu();
            },
          ),
        );
      } else {
        print("GoogleLogin");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return GoogleLogin();
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FlutterSplashScreen.fadeIn(
                backgroundColor: Colors.white,
                onInit: () {
                  debugPrint("On Init");
                },
                onEnd: () {
                  debugPrint("On End");
                },
                childWidget: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/whomanalytic_logo.png"),
                ),
                onAnimationEnd: () => debugPrint("On Fade In End"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
