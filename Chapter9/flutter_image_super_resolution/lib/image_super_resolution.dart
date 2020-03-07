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
  
  Image img1 = Image(  width: 200, height: 200, image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),);

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Super Resolution')
      ),
      body: Container(
      child: Column(
        children: <Widget> [
          buildImageRow(),
          buildPickImageButton()
        ]
      )
    )
    );
  }

  Widget buildImageRow() {

    return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        img1,
        img1
      ],
    )
    );
  }

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
      // var responseData = json.decode(response.body);
      // print("FETCH RESPONSE: ${response.statusCode}, ${response.toString()}");

    } catch (e) {
      print(e);
      return null;
    }
  }

  // void loadImage(File file) async {
  //   final data = await file.readAsBytes();
  //   await decodeImageFromList(data).then(
  //     (value) => setState(() {
  //       img1 = value as Image;
  //     }),
  //   );
  // }

  void loadImage(File file) {
    setState(() {
      img1 =Image.file(file);
    });
  }

}