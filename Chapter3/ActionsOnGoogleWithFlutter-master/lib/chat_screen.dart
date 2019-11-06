import 'package:flutter/material.dart';
import 'package:actions_on_google_with_flutter/chat_message.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:speech_recognition/speech_recognition.dart';

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String transcription = '';

  @override
  void initState(){
    super.initState();
    activateSpeechRecognizer();
  }

  void activateSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler((bool result)
    => setState(() => _isAvailable = result));


    _speechRecognition.setRecognitionStartedHandler(()
    => setState(() => _isListening = true));

    _speechRecognition.setRecognitionResultHandler((String text)
    => setState(() => transcription = text));

    _speechRecognition.setRecognitionCompleteHandler(()
    => setState(() => _isListening = false));

    _speechRecognition
        .activate()
        .then((res) => setState(() => _isAvailable = res));
  }


  Future _handleSubmitted(String query) async {
    AuthGoogle authGoogle = await AuthGoogle(fileJson: "assets/gcp-api.json").build();
    Dialogflow dialogflow = Dialogflow(authGoogle: authGoogle,language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    print(response.getMessage());
    String rsp = response.getMessage();

    _textController.clear();
    ChatMessage message = new ChatMessage(
      query: query, response: rsp,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration:
                new InputDecoration.collapsed(hintText: "Enter your message"),
                controller: _textController,
                onSubmitted: _handleSubmitted,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.mic),
                  onPressed: () {
                    if(_isAvailable && !_isListening) {
                      _speechRecognition.recognitionStartedHandler();
                      _speechRecognition
                          .listen(locale: "en_US")
                          .then((transcription) => print('$transcription'));
                    } else if(_isListening) {
                      _isListening = false;
                      transcription = '';
                      _handleSubmitted(transcription);
                      _speechRecognition.stop().then(
                              (result) => setState(() => _isListening = result));
                    }
                  } //Pressed
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Flexible(
          child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _buildTextComposer(),
        ),
      ],
    );
  }
}