import 'package:flutter/material.dart';

const String _name = "Test User";

class ChatMessage extends StatelessWidget {
  final String query, response;
  ChatMessage({this.query, this.response});

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: new Text(query,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black45,
                  ),
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: new Text(response,
                  style: TextStyle(
                      fontSize: 16.0
                  ),
                ),
              )
            ]
        )
    );
  }
}
