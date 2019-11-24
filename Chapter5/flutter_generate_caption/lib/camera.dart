import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  Camera(this.cameras);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;
  
  @override
  void initState() {
    super.initState();
    print("INSIDE CAMERA");
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      print("INITIALIZING CONTROLLER");
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );
      controller.initialize().then((_) {
        if (!mounted) {
        return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          print("IMAGE STREAMING");
          if (!isDetecting) {
            isDetecting = true;
            int startTime = new DateTime.now().millisecondsSinceEpoch;  
          }
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxHeight: 200,
      maxWidth: 200,
      child: CameraPreview(controller),
    );
    //return Container(child: Text('Container'),);
  }
}