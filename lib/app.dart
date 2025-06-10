import 'package:flutter/material.dart';
import 'package:mobileapp_final/camera_capture.dart';
import 'package:mobileapp_final/home.dart';
import 'package:mobileapp_final/list.dart';
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
        '/image': (BuildContext context) => const ImagePage(),
        '/result': (BuildContext context) => const ResultPage(),
        '/list': (BuildContext context) => const ListPage(),
        '/profile': (BuildContext context) => const ProfilePage(),
        '/camera': (BuildContext context) => const CameraCapturePage(),
        '/home': (BuildContext context) => const HomePage(),
      },

      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 12, 63, 151),
        ),
      ),
    );
  }
}
