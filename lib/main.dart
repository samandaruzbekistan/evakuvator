import 'package:evakuvator/screens/auth/intro.dart';
import 'package:evakuvator/screens/counter.dart';
import 'package:evakuvator/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7643)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


