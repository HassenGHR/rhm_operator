import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rhm_operator/screens/home_screen.dart';

void main() {
  runApp(const RefineryApp());
}

class RefineryApp extends StatelessWidget {
  const RefineryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refinery Process Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}