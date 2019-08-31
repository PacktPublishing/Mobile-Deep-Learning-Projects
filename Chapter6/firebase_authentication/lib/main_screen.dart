import 'package:flutter/material.dart';

import 'package:firebase_authentication/signup_signin_screen.dart';
import 'package:firebase_authentication/auth.dart';
import 'package:firebase_authentication/home_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _MainScreenState();
}

enum AuthStatus {
  SIGNED_OUT,
  SIGNED_IN,
}

class _MainScreenState extends State<MainScreen> {
  AuthStatus authStatus = AuthStatus.SIGNED_OUT;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user;
        }
        authStatus =
            user == null ? AuthStatus.SIGNED_OUT : AuthStatus.SIGNED_IN;
      });
    });
  }

  void _onSignedIn() {
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _userId = user;
      });
    });
    setState(() {
      authStatus = AuthStatus.SIGNED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.SIGNED_OUT;
      _userId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if(authStatus == AuthStatus.SIGNED_OUT) {
      return new SignupSigninScreen(
        auth: widget.auth,
        onSignedIn: _onSignedIn,
      );
    } else {
      return new HomeScreen(
        userId: _userId,
        auth: widget.auth,
        onSignedOut: _onSignedOut,
        );
    }
  }
}