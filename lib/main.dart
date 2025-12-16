import 'package:flutter/material.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Diary',
      theme: ThemeData(
        useMaterial3: true,
        // This color scheme matches your purple/blue design
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A5AE0)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
