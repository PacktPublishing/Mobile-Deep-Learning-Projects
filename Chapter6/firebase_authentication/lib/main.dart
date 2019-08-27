import 'package:flutter/material.dart';
import 'package:firebase_authentication/auth.dart';
import 'package:firebase_authentication/main_screen.dart';
import 'package:firebase_authentication/home_screen.dart';

void main() {
  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter login demo',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new HomeScreen());
  }
}