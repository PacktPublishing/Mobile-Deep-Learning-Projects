import 'package:flutter/material.dart';
import 'generate_caption.dart';
import 'camera_preview.dart';
import 'package:camera/camera.dart';

//void main() => runApp(MyApp());

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraApp(cameras)
    );
  }
}

