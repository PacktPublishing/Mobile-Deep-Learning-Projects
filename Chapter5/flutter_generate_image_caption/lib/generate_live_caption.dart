import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart'  as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
   final String filePath = '$dirPath/${timestamp}.png';
   controller.takePicture(filePath).then((_){
     File imgFile = File(filePath);
     FetchResponse(imgFile);
     });
  }

  Future<Map<String, dynamic>> FetchResponse(File image) async {
    
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            "http://max-image-caption-generator-mytest865.apps.us-east-2.starter.openshift-online.com/model/predict"));
    
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = json.decode(response.body);
      parseResponse(responseData);
      return responseData;

    } catch (e) {
      print(e);
      return null;
    }
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