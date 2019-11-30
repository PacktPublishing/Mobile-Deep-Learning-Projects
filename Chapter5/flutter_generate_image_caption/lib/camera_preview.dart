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
    controller.takePicture(filePath).then((_){
      print('FILE PATH:: ${filePath}');
    var s = Image.file(File(filePath));
    File f = File(filePath);
    String base64Image = base64Encode(f.readAsBytesSync());
    print('IMAGE FILE:  $s');
    
    //getResponse(filePath);
    responsive(f);
    });
}

Future<void> responsive(File img) async {
    var url = 'http://104.154.147.60:8000/predict';
    Map<String, String> headers = {"accept": "application/json", "Content-Type": "multipart/form-data"};
    // //String base64Image = base64Encode(img.readAsBytesSync());
    // String js = '{"image": ${img}}';  // make POST request
    // final response = await http.post(url, headers: headers, body: js);

    String base64Image = base64Encode(img.readAsBytesSync());
    String fileName = img.path.split("/").last;

    print(base64Image);
    
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

// [{index: 0, caption: a laptop computer sitting on top of a bed ., probability: 0.000875693544750408}, 
// {index: 1, caption: a laptop computer sitting on top of a table ., probability: 0.00016174037799549445}, 
// {index: 2, caption: a laptop computer sitting on top of a wooden table ., probability: 0.00015052834799119907}]}

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



// Future<void> getResponse (String f) async {
//   var url = 'http://api-os-max.apps.us-east-2.starter.openshift-online.com/model/predict';
//   Dio dio = new Dio();
//   FormData formdata = new FormData();
//   Map<String, String> headers = {"accept": "application/json", "Content-Type":"multipart/form-data"};


//   FormData formData = FormData.fromMap({

//     "image": await MultipartFile.fromFile(f)
// });
// final response= await dio.post(url, data: formData);

//   // formdata.add("image", new UploadFileInfo(f, basename(f.path)));
//   // String js = '{"image":${f}}';
//   // final response =
//   //     await http.post(url, headers: headers, body: js);
//    print("RESPONSE CODE ${response.statusCode}");
//    var j = json.decode(response.data);
//     print('RESPONSE:: ${j}');

// }


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
    //final size = MediaQuery.of(context).size;
    var size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('Generate Image Caption'),),
    body: Container(
      child: Column(
        children: <Widget>[
          
          Container(
              width: size,
              height: size,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      width: size,
                      height: size / controller.value.aspectRatio,
                      child: CameraPreview(
                          controller), // this is my CameraPreview
                    ),
                  ),
                ),
              ),
            ),
            Text(rsp),  
        ],
      ),
    ));
  //   return   Container(
  //   width: size,
  //   height: size,
  //   child: ClipRect(
  //     child: OverflowBox(
  //       alignment: Alignment.center,
  //       child: FittedBox(
  //         fit: BoxFit.fitWidth,
  //         child: Container(
  //           width: size,
  //           height:
  //               size / controller.value.aspectRatio,
  //           child: CameraPreview(controller), // this is my CameraPreview
  //         ),
  //       ),
  //     ),
  //   ),
  // );
  }
}