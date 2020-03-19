import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ImageSuperResolution extends StatefulWidget {
  @override
  _ImageSuperResolutionState createState() => _ImageSuperResolutionState();
}

class _ImageSuperResolutionState extends State<ImageSuperResolution> {
  var img1 = Image.asset(
    'assets/place_holder_image.png',
    fit: BoxFit.contain,
  );

  Widget imageOutput = Image.asset('assets/place_holder_image.png');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Image Super Resolution')),
        body: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildImageInput(),
                  buildImageOutput(),
                  buildPickImageButton()
                ])));
  }

  var url =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';


  Widget buildImageInput() {
    return Expanded(
      child: Container(
        width: 200, 
        height: 200, 
        child: img1
      )
    );
  }

    Widget buildImageOutput() {
    return Container(
        child: SizedBox(
            width: 200, 
            height: 200, 
            child: imageOutput
          )
    );
  }

  Widget buildPickImageButton() {
    return Container(
        margin: EdgeInsets.all(8),
        child: FloatingActionButton(
          elevation: 8,
          onPressed: () => pickImage(),
          child: Icon(Icons.camera_alt),
        ));
  }

  void pickImage() async {
    File pickedImg = await ImagePicker.pickImage(source: ImageSource.gallery);
    loadImage(pickedImg);
    fetchResponse(pickedImg);
  }

  void fetchResponse(File image) async {
    print('Fetch Response Called');

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse("http://35.223.166.50:8080/generate"));

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
      displayResponseImage(outputFile);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void displayResponseImage(String outputFile) {
    print("Updating Image");
    outputFile = 'http://35.223.166.50:8080/download/' + outputFile;
    setState(() {
      imageOutput = Image(image: NetworkImage(outputFile));
    });
  }

  void loadImage(File file) {
    setState(() {
      img1 = Image.file(file);
    });
  }
}
