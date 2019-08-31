import 'package:flutter/material.dart';
import 'package:firebase_authentication/auth.dart';
import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';

class SignupSigninScreen extends StatefulWidget {
  SignupSigninScreen({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _SignupSigninScreenState();
}

enum FormMode { SIGNIN, SIGNUP }

class MaliciousUserException implements Exception { 
   String message() => 'Malicious login! Please try later.'; 
}  

class _SignupSigninScreenState extends State<SignupSigninScreen> {
  
  final _formKey = new GlobalKey<FormState>();
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  String _usermail;
  String _userpassword;
  String _errorMessage;

  // Start with Signin form mode
  FormMode _formMode = FormMode.SIGNIN;
  bool _iosDevice;
  bool _loading;

  // Validate the form before perform signin or signup
  bool isValidForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Signin or signup
  void _signinSignup() async {
    setState(() {
      _errorMessage = "";
      _loading = true;
    });
    if (isValidForm()) {
      String userId = "";
      try {
        if (_formMode == FormMode.SIGNIN) {
          var val = await widget.auth.isValidUser(_usermail, _userpassword);
          if(val < 0.20) {
            throw new MaliciousUserException();
          }
          userId = await widget.auth.signIn(_usermail, _userpassword);
        } else {
          userId = await widget.auth.signUp(_usermail, _userpassword);
        }
        setState(() {
          _loading = false;
        });

        if (userId != null && userId.length > 0 && _formMode == FormMode.SIGNIN) {
          widget.onSignedIn();
        }

      } catch(MaliciousUserException) {
        setState(() {
          _loading = false;
            _errorMessage = 'Malicious user detected. Please try again later.';
        });
      }  
      catch (e) {
        print('Error: $e');
        setState(() {
          _loading = false;
          if (_iosDevice) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }


  @override
  void initState() {
    _errorMessage = "";
    _loading = false;
    super.initState();
  }

  void _switchFormToSignUp() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _switchFormToSignin() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode.SIGNIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _iosDevice = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Firebase Authentication'),
        ),
        body: Stack(
          children: <Widget>[
            _createBody(),
            _createCircularProgress(),
            _createRecaptcha()
          ],
        ));
  }

  Widget _createCircularProgress(){
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);
  }

  Widget _createBody(){
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _createUserMailInput(),
              _createPasswordInput(),
              _createSigninButton(),
              _createSigninSwitchButton(),
              _createErrorMessage(),
            ],
          ),
        ));
  }

  Widget _createErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _createUserMailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _usermail = value.trim(),
      ),
    );
  }

  Widget _createPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _userpassword = value.trim(),
      ),
    );
  }

  Widget _createSigninSwitchButton() {
    return new FlatButton(
      child: _formMode == FormMode.SIGNIN
          ? new Text('Create an account',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.SIGNIN
          ? _switchFormToSignUp
          : _switchFormToSignin,
    );
  }

  Widget _createSigninButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: _formMode == FormMode.SIGNIN
                ? new Text('SignIn',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Create account',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: recaptchaV2Controller.show,
          ),
        ));
  }

  Widget _createRecaptcha() {
    return RecaptchaV2(
      apiKey: "Enter Site Key here", // for enabling the reCaptcha
      apiSecret: "Enter API Key here", // for verifying the responded token
      controller: recaptchaV2Controller,
      onVerifiedError: (err){
        print(err);
      },
      onVerifiedSuccessfully: (success) {
        setState(() {
        if (success) {
          _signinSignup();
        } else {
          print('Failed to verify');
        }
        });
      },
    );
  }  
}