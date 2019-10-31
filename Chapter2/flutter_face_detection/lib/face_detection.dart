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
  List<Face> faces;

  @override
  Widget build(BuildContext context) {
    detectFaces();
    return  Scaffold(
      appBar: AppBar(),
      body: Container(
      child: Column(
        children: <Widget>[
             Image.file(widget.file),
             //faceDetectList(faces),
        ],
      ),
    ));
  }

  void detectFaces() async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    faces = await faceDetector.processImage(visionImage);
    print("DETECTED FACES: $faces");
    faceDetectList(faces);
  }

  Widget faceDetectList(List<Face> labels) {
    print("$labels");
    if (labels != null) {
      print("Labels is not null $labels.length");
      if (labels.length == 0) {
        print("Labels length is zero");
        return Expanded(
          flex: 1,
          child: Center(
            child: Text('Nothing detected'),
          ),
        );
      }
      return Expanded(
        flex: 1,
        child: Container(
          child: ListView.builder(
              padding: const EdgeInsets.all(1.0),
              itemCount: labels != null ? labels.length : 0,
              itemBuilder: (context, i) {
                var text;
                final face = labels[i];
                Face res = face;
                text = "Raw Value for face: Smiling Probablity: ${res.smilingProbability} with tracking id ${res.trackingId}";
                print("VALUE $text");
                return _buildTextRow(text);
              }),
        ),
      );
    }
    print("Label is null");
    return Container();
  }

    Widget _buildTextRow(text) {
      print("Build list row called");
    return ListTile(
      title: Text(
        "$text",
      ),
      dense: true,
    );
  }
}