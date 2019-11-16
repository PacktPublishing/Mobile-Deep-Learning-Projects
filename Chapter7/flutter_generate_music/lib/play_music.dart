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
  String result;
  String load_text = 'Generate Music';

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
          buildGenerateButton(),
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
        child: Text(load_text)
      )
    );
  }

  Widget buildStopButton() {
    return Padding( 
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      child: RaisedButton(
        child: Text("Stop"),
        onPressed: (){
          audioPlayer.stop();
        },
        color: Colors.blue,
        textColor: Colors.white,
      )
    );
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
    var url = baseUrl + output;
    AudioPlayer.logEnabled = true;
    int result = await audioPlayer.play(url);
    if (result == 1) {
      print('Success');
      }
  }

  void load() {
    setState(() {
     load_text = 'Generating...'; 
    });
    Future<Response> rsp;
    rsp = fetchResponse();
    print('LOAD: $rsp');
  }

  Future<Response> fetchResponse() async {
    final response =
      await http.get('http://34.70.80.18:8000/generate').whenComplete((){
        setState(() {
         load_text = 'Generation Complete'; 
        });
      });
    print('VALUE: ${response.statusCode}');
    if (response.statusCode == 200) {
      var v = json.decode(response.body);
      output = v["result"] ;
      print('Response: $output');
      return Response.fromJson(json.decode(response.body));
    } else {
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