import 'package:flutter/material.dart';
import 'package:recomendator_app/screens/login_screen.dart';
import 'package:recomendator_app/screens/register_screen.dart';
import 'package:recomendator_app/screens/welcome_screen.dart';
import 'package:recomendator_app/screens/video_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recomedator App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/video': (context) => const VideoScreen(username: '', userId: '',),
      },
    );
  }
}
