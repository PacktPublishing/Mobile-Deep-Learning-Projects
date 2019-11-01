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
  ui.Image image;
  List<Face> _faces;
  var result = "";

  @override
  void initState() {
    super.initState();
    detectFaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Detection"),
      ),
      body: (image == null) ? Center(child: CircularProgressIndicator(),): 
      Center(
        child: FittedBox(
          child: SizedBox(
            width: image.width.toDouble(),
            height: image.width.toDouble(),
            child: CustomPaint(painter: FacePainter(image, _faces))
          ),
        ),
      )
    );
  }

   _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        image = value;
      }),
    );
  }


  void detectFaces() async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableClassification: true
        ));
    List<Face> faces = await faceDetector.processImage(visionImage);
    for (var i = 0; i < faces.length; i++) {
      final double smileProb = faces[i].smilingProbability;
      print("Smiling:: $smileProb");
    }
    setState(() {
      _faces = faces;
      _loadImage(widget.file);
    });
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}