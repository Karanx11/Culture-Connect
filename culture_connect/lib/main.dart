import 'package:culture_connect/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Culture Connect',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}
