import 'package:flutter/material.dart';
import 'package:firebase_authentication/auth.dart';

class HomeScreen extends StatefulWidget {
  // HomeScreen({Key key, this.auth, this.userId, this.onSignedOut})
  //     : super(key: key);

  // final BaseAuth auth;
  // final VoidCallback onSignedOut;
  // final String userId;

  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // _signOut() async {
  //   try {
  //     await widget.auth.signOut();
  //     widget.onSignedOut();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  //String text = widget.auth.getLoginResponse();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Firebase Authentication'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 16.0, color: Colors.white)),
                //onPressed: _signOut
                )
          ],
        ),
         body: Center(child: new Text('Hello User', 
         style: new TextStyle(fontSize: 28.0))
         ),
    );
  }
}