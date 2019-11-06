import 'package:flutter/material.dart';
import 'package:actions_on_google_with_flutter/home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: "Dialog Flow", home: new HomePage());
  }
}