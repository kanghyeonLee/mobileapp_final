import 'package:flutter/material.dart';
import 'package:mobileapp_final/home.dart';
import 'package:mobileapp_final/image.dart';
import 'package:mobileapp_final/profile.dart';
import 'package:mobileapp_final/result.dart';
import 'login.dart';

class SyncYourSnapApp extends StatelessWidget {
  const SyncYourSnapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync Your Snap',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/': (BuildContext context) => const HomePage(),
        '/image': (BuildContext context) => const ImagePage(),
        '/result': (BuildContext context) => const ResultPage(),
        '/home': (BuildContext context) => const HomePage(),
        '/profile': (BuildContext context) => const ProfilePage(),
      },
     
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey,
        ),
      ),
    );
  }
}