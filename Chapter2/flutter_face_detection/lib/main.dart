import 'package:flutter/material.dart';
import 'face_detection_home.dart';

void main() => runApp(new FaceDetectorApp());

class FaceDetectorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FaceDetectorHome(),
    );
  }
}