import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const GraviFallApp());
}

class GraviFallApp extends StatelessWidget {
  const GraviFallApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraviFall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Courier', // Gives a nice retro space vibe
      ),
      home: GameScreen(),
    );
  }
}
