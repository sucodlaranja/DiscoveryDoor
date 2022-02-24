import 'dart:async';

import 'package:discovery_door/aux/colors.dart';
import 'package:discovery_door/aux/methods.dart';
import 'package:discovery_door/screens/app_start/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // late bool _isLoading;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    final permission = Geolocator.requestPermission();
    permission.then(
      (value) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: screenWidth(context),
        height: screenHeight(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kScreenDark,
              kScreenLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 200 * unitHeightValue(context),
              ),
              child: Image.asset(
                "assets/appimages/Museum.png",
                height: 95 * unitHeightValue(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 400 * unitHeightValue(context),
              ),
              child: SpinKitFoldingCube(
                color: kLetter,
                size: 35 * unitWidthValue(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
