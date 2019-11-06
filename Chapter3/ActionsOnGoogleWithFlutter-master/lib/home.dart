import 'package:flutter/material.dart';
import 'package:actions_on_google_with_flutter/chat_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Dialog Flow"),
        ),
        body: new ChatScreen());
  }
}