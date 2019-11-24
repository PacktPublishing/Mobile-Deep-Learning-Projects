import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CameraDescription> cameras;
  @override 
  void initState() {
    _initCamera();
    }


CameraController _controller;
_initCamera() {
  getLength();
}

Future<int> getLength() async {
  cameras = await availableCameras().whenComplete((){
    return cameras.length;
  });
}


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          //Camera(cameras),
          Text('Here is the text')
        ],
      )
    );
  }
}