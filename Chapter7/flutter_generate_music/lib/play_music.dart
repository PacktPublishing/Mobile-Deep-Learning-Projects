import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class PlayMusic extends StatefulWidget {
  @override
  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {

  AudioPlayer audioPlayer = AudioPlayer();

   @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Play Music"),
      ),
      body: Column(
        children: <Widget>[
          buildPlayButton(),
          buildStopButton(),
          buildGenerateButton()
        ],
      )
    );
  }

  Widget buildPlayButton() {
    return Center(
      child: RaisedButton(
        child: Text("Play"),
        onPressed: () {
           play();
        },
        ),
      );
  }

  Widget buildStopButton() {
    return Center(
      child: RaisedButton(
        child: Text("stop"),
        onPressed: (){
          audioPlayer.stop();
        },
      )
      );
  }

  Widget buildGenerateButton() {
    return Center(
      child: RaisedButton(
        child: Text("Generate Music"),
        onPressed: () {
          load();
        },
        ),
      );
  }


      play() async {
        var url = 'http://34.70.80.18:8000/download/output_1573589840.mid';
        AudioPlayer.logEnabled = true;
        int result = await audioPlayer.play(url);
        if (result == 1) {
          print('Success');
      }

  
    }


  

  void load() {
    Future<Response> rsp;
    rsp = fetchResponse();
    print('LOAD: $rsp');
  }

  Future<Response> fetchResponse() async {
  final response =
      await http.get('http://34.70.80.18:8000/generate');

  if (response.statusCode == 200) {
    var v = json.decode(response.body);
    return Response.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    print('FAILURE');
    throw Exception('Failed to load post');
  }
}
}

class Response {
  String response;
  Response(this.response);
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(json['result']);
  }
}