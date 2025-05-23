import 'package:flutter/material.dart';
import 'package:mobileapp_final/home.dart';
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
        '/':(BuildContext context) => const HomePage()
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