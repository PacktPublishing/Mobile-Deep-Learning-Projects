import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera.dart';

class Home extends StatefulWidget {
  List<CameraDescription> camera;
  Home(this.camera);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Camera(widget.camera),
          Text('Here is the text')
        ],
      )
    );
  }
}