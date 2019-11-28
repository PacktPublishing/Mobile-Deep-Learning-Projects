import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_preview.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp(cameras));
}

