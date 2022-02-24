import 'package:discovery_door/screens/app_start/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DiscoveryDoorApp());
}

class DiscoveryDoorApp extends StatelessWidget {
  const DiscoveryDoorApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discovery Door',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
