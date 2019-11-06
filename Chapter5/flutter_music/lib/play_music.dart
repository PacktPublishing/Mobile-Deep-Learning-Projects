import 'package:flutter/material.dart';

class PlayMusic extends StatefulWidget {
  @override
  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Play Music"),
      ),
      body: Column(
        children: <Widget>[
          buildPlayButton(),
          buildGenerateButton()
        ],
      )
    );
  }

  Widget buildPlayButton() {
    return Center(
      child: RaisedButton(
        child: Text("Play"),
        onPressed: () {},
        ),
      );
  }

  Widget buildGenerateButton() {
    return Center(
      child: RaisedButton(
        child: Text("Generate Music"),
        onPressed: () {},
        ),
      );
  }
}