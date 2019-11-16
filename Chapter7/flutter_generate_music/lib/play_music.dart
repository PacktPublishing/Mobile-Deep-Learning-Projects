import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayMusic extends StatefulWidget {
  @override
  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {

  AudioPlayer audioPlayer = AudioPlayer();
  String baseUrl = 'http://34.70.80.18:8000/download/';
  String fileName;
  String loadText = 'Generate Music';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generate Play Music"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildGenerateButton(),
          buildPlayButton(),
          buildStopButton(),
          buildLoadingText()
        ],
      )
    );
  }

  Widget buildPlayButton() { 
    return Padding(
    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
    child: RaisedButton(
      child: Text("Play"),
      onPressed: () {
        play();
      },
      color: Colors.blue,
      textColor: Colors.white,
      ),
    );
  }

  Widget buildLoadingText() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text(loadText)
      )
    );
  }

  Widget buildStopButton() {
    return Padding( 
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: RaisedButton(
        child: Text("Stop"),
        onPressed: (){
          stop();
        },
        color: Colors.blue,
        textColor: Colors.white,
      )
    );
  }

  void stop() {
    audioPlayer.stop();
  }

  Widget buildGenerateButton() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: RaisedButton(
        child: Text("Generate Music"),
        onPressed: () {
          load();
        },
        color: Colors.blue,
        textColor: Colors.white,
      ),
    );
  }

  play() async {
    var url = baseUrl + fileName;
    AudioPlayer.logEnabled = true;
    int result = await audioPlayer.play(url);
    if (result == 1) {
      print('Success');
      }
  }

  void load() {
    setState(() {
     loadText = 'Generating...'; 
    });
    fetchResponse();
  }

  void fetchResponse() async {
    final response =
      await http.get('http://35.225.134.65:8000/generate').whenComplete((){
        setState(() {
         loadText = 'Generation Complete'; 
        });
      });
    print('VALUE: ${response.statusCode}');
    if (response.statusCode == 200) {
      var v = json.decode(response.body);
      fileName = v["result"] ;
      print('Response: $fileName');
    } else {
      print('FAILURE');
      throw Exception('Failed to load');
    }
  }
}
