import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart'  as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
  List<CameraDescription> cameras;
  CameraApp(this.cameras);
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  String rsp = "Fetching Response..";

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      const oneSec = const Duration(seconds:5);
      new Timer.periodic(oneSec, (Timer t) => capturePictures());
    });
  }

 capturePictures() async {
   String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
   final Directory extDir = await getApplicationDocumentsDirectory();
   final String dirPath = '${extDir.path}/Pictures/flutter_test';
   await Directory(dirPath).create(recursive: true);
   final String filePath = '$dirPath/${timestamp()}.jpg';
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
      print(res.statusCode);
      print(res);
      var r = json.decode(res.body);
      parseResponse(r);
    }).catchError((err) {
      print(err);
    });
  }

  void parseResponse(var reponse) {
    String r = "";
    var p = reponse['predictions'];
    var l = p.length;
    int i;
    for(i = 0; i < l; i++){
      var caption = p[i]['caption'];
      var probablity = p[i]['probability'];
      r = r + '${caption}: ${probablity}\n';
    } 
    setState(() {
      rsp= r;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return _buildCameraPreview();
  }

  Widget _buildCameraPreview() {
    var size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Image Caption'),),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                child: Container(
                  width: size,
                  height: size / controller.value.aspectRatio,
                  child: CameraPreview(
                    controller
                  ),
                ),
              ),
              Text(rsp),  
          ]
        ),
      )
    );
  }
}