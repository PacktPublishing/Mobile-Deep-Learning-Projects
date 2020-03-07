import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:ui' as ui;

class ImageSuperResolution extends StatefulWidget {
  @override
  _ImageSuperResolutionState createState() => _ImageSuperResolutionState();
}

class _ImageSuperResolutionState extends State<ImageSuperResolution> {

  var img1 = Image.asset('assets/place_holder_image.png');
  var img2 = Image.asset('assets/place_holder_image.png');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Super Resolution')
      ),
      body: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          buildImage1(),
          buildImage2(),
          buildPickImageButton()
        ]
      )
    )
    );
  }


  Widget buildImage1() {
    return Container (
      height: 200, 
      width: 200,
      child: img1
    );
  }

  Widget buildImage2() {
    return Container (
      width: 200,
      height: 200,
      child: img2
      );
  }

  // Widget buildImageRow() {
  //   return Container (
  //     width: 200,
  //     height: 200,
  //     child: Image(image: NetworkImage('http://35.223.166.50:8080/download/output_1583568677.png'))
  //   );
  // }

  Widget buildPickImageButton() {
    return FloatingActionButton( 
      elevation: 2 ,
      onPressed: () => pickImage(), 
      child: Icon(Icons.camera_alt),);
  }

  void pickImage() async{
    File pickedImg = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('PICK Image Called');
    loadImage(pickedImg);
    fetchResponse(pickedImg);
  }

  void fetchResponse(File image) async {

    print('Fetch Response Called');
    
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');
    
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse("http://35.223.166.50:8080/generate"));
    
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(' Status Code: ${response.statusCode}');
      final Map<String, dynamic> responseData = json.decode(response.body);
      String outputFile = responseData['result'];

    } catch (e) {
      print(e);
      return null;
    }
  }

  void displayResponseImage(String outputFile) {
    outputFile = 'http://35.223.166.50:8080/download/' + outputFile;
    setState(() {
      img2 = NetworkImage(outputFile) as Image;
    });
  }

  void loadImage(File file) {
    setState(() {
      img1 = Image.file(file);
    });
  }

}