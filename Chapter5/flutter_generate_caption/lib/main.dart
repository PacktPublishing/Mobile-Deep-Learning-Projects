// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'home.dart';

// List<CameraDescription> cameras;

// main() {
//   runApp(new MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'tflite real-time detection',
//       theme: ThemeData(
//         brightness: Brightness.dark,
//       ),
//       home: Home(),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart'  as http;
import 'package:dio/dio.dart';
import 'dart:convert';


List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;

  @override
  void initState() {
    
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      const oneSec = const Duration(seconds:5);
      new Timer.periodic(oneSec, (Timer t) => takePics());
    });
  }

 takePics() async {
   print("TAKE PICS CALLED");
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    controller.takePicture(filePath);
    print('FILE PATH:: ${filePath}');
    getResponse(filePath);

}

Future<void> getResponse (String filePath) async {
  var url = 'http://api-os-max.apps.us-east-2.starter.openshift-online.com/model/predict';
  
  Dio dio = new Dio();
  
  FormData formdata = new FormData();
  
  Map<String, String> headers = {"accept": "application/json", "Content-Type":"multipart/form-data"};


  FormData formData = FormData.fromMap({

    "image": await MultipartFile.fromFile("assets/img.jpg")
});
final response= await dio.post(url, data: formData);
   print("RESPONSE CODE ${response.statusCode}");
   var j = json.decode(response.data);
    print('RESPONSE:: ${j}');

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
    return AspectRatio(
        aspectRatio:
        controller.value.aspectRatio,
        child: CameraPreview(controller));
  }
}