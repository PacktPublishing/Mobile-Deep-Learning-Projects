import 'package:flutter/material.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';

class PlayMusic extends StatefulWidget {
  @override
  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {

   @override
  void initState() {
    load('assets/sample1.mid');
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
           FlutterMidi.playMidiNote(midi: 60);
        },
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

   void load(String asset) async {
    FlutterMidi.unmute(); // Optionally Unmute
    ByteData _byte = await rootBundle.load(asset);
    FlutterMidi.prepare(sf2: _byte);
  }

}