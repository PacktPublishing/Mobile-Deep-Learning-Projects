import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class PlantSpeciesRecognition extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PlantSpeciesRecognitionState();
}

class _PlantSpeciesRecognitionState extends State<PlantSpeciesRecognition> {

  File _image;
  List _recognitions;
  bool _busy = false;

  Future predictImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _busy = true;
    });

    await loadModel();
    await recognizeImage(image);

    setState(() {
      _image = image;
      _busy = false;
    });
  }

  Future loadModel() async {
    Tflite.close();

    String res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1 // defaults to 1
    );
    print('Model Loaded: $res');
  }

  Future recognizeImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path
    );
    setState(() {
      _recognitions = recognitions;
    });
    print('Recognition Result: $_recognitions');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    Size size = MediaQuery.of(context).size;

    stackChildren.clear();

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? new Center(child: Text('No Image Selected')) : Image.file(_image),
    ));

    stackChildren.add(Center(
      child: Column(
        children: _recognitions != null
            ? _recognitions.map((res) {
          return Text(
            "${res["label"]}: ${res["confidence"].toStringAsFixed(3)}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              background: Paint()..color = Colors.white,
            ),
          );
        }).toList() : [],
      ),
    ));


    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Species Recognition'),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: predictImagePicker,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}
