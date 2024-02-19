import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whomii/Login/GoogleLogin.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() => runApp(MyApp());

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
  StartFunction() async {}
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () async {
      prefsLogin = await SharedPreferences.getInstance();
      // set value

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return GoogleLogin(
              title: 'Naber',
            );
          },
        ),
      );
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
                nextScreen: GoogleLogin(
                  title: 'NABER',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
