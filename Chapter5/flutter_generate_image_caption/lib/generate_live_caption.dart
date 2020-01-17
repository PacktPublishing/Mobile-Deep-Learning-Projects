import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart'  as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';

class GenerateLiveCaption extends StatefulWidget {
  @override
  _GenerateLiveCaptionState createState() => _GenerateLiveCaptionState();
  GenerateLiveCaption();
}

class _GenerateLiveCaptionState extends State<GenerateLiveCaption> {
  CameraController controller;
  String resultText = "Fetching Response..";
  List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();   
    detectCameras().then((_){
      initializeController();
    });
  }

  void initializeController() {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        const interval = const Duration(seconds:5);
        new Timer.periodic(interval, (Timer t) => capturePictures());
    });
  }

  Future<void> detectCameras() async {
    cameras = await availableCameras();
  }

 capturePictures() async {
   String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
   final Directory extDir = await getApplicationDocumentsDirectory();
   final String dirPath = '${extDir.path}/Pictures/flutter_test';
   await Directory(dirPath).create(recursive: true);
   final String filePath = '$dirPath/${timestamp}.jpg';
   controller.takePicture(filePath).then((_){
     File imgFile = File(filePath);
     fetchResponse(imgFile);
     });
  }

  Future<void> fetchResponse(File imgFile) async {
    var url = 'http://104.154.147.60:8000/predict';

    String base64Image = base64Encode(imgFile.readAsBytesSync());
    String fileName = imgFile.path.split("/").last;
    
    http.post(url, body: {
      "image": base64Image,
      "name": fileName,
    }).then((res) {
      var resString = json.decode(res.body);
      parseResponse(resString);
    }).catchError((err) {
      print(err);
    });
  }

  void parseResponse(var response) {
    String r = "";
    var predictions = response['predictions'];
    for(var prediction in predictions) {
      var caption = prediction['caption'];
      var probability = prediction['probability'];
      r = r + '${caption}: ${probability}\n\n';
    }
    setState(() {
      resultText = r;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Image Caption'),),
      body: (controller.value.isInitialized)? buildCameraPreview():new Container(),
      );
  }

  Widget buildCameraPreview() {
    var size = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            child: CameraPreview(controller),
          ),
          Text(resultText),
        ]
      )
    );
  }
}