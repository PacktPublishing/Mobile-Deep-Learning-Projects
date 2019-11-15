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
  var baseUrl = 'http://34.70.80.18:8000/download/';
  var output = 'output_1573589840.mid';

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
          buildPlayButton(),
          buildStopButton(),
          buildGenerateButton()
        ],
      )
    );
  }

  Widget buildPlayButton() {
    
     return Padding(
       padding: EdgeInsets.all(16),
       child: RaisedButton(
        child: Text("Play"),
        onPressed: () {
           play();
        },
        ),
      );
  }

  Widget buildStopButton() {
    return Padding( 
      padding: EdgeInsets.all(16),
      child: RaisedButton(
        child: Text("stop"),
        onPressed: (){
          audioPlayer.stop();
        },
        
      )
      );
  }

  Widget buildGenerateButton() {
     return Padding(
       padding: EdgeInsets.all(16),
       child: RaisedButton(
        child: Text("Generate Music"),
        onPressed: () {
          load();
        },
        color: Colors.blue,
        ),
      );
  }


      play() async {
        var url = baseUrl + output;
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
  print('VALUE: ${response.statusCode}');
  if (response.statusCode == 200) {
    var v = json.decode(response.body);
    var l = v["result"] ;
    print('Response: ${l}');
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