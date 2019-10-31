import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:ui' as ui;

class FaceDetection extends StatefulWidget {

  final File file; 
  FaceDetection(this.file);

  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  var _image;

  @override
  Widget build(BuildContext context) {
    detectFaces();
    return  Scaffold(
      appBar: AppBar(),
      body: Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Image.file(widget.file),
          )
        ],
      ),
    ));
  }

  void detectFaces() async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    final List<Face> faces = await faceDetector.processImage(visionImage);
    print("Detected: $faces");
  }
}