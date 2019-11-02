import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'face_detection.dart';

class FaceDetectorHome extends StatefulWidget {
  FaceDetectorHome({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FaceDetectorHomeState();
}

class _FaceDetectorHomeState extends State<FaceDetectorHome> {
  File image;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Face Detection'),
        ),
        body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildRowTitle(context, 'Pick Image'),
                buildSelectImageRowWidget(context)
              ],
            )
        )
    );
  }

  Widget buildRowTitle(BuildContext context, String title) {
    return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headline,
          ),
        )
    );
  }

  Widget buildSelectImageRowWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        createButton('Camera'),
        createButton('Gallery')
      ],
    );
  }

  Widget createButton(String imgSource) {
    return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              splashColor: Colors.blueGrey,
              onPressed: () {
                onPickImageSelected(imgSource);
              },
              child: new Text(imgSource)),
        )
    );
  }


  onPickImageSelected(String imgSource) async {
    var src;
    if(imgSource == 'Gallery')
      src = ImageSource.gallery;
    else
      src = ImageSource.camera;
    File img = await ImagePicker.pickImage(source: src);
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => FaceDetection(img)),
    );
  }
}