import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:http/http.dart' as http;

class ChessGame extends StatefulWidget {
  

var size= 200;

  @override
  _ChessGameState createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {

    var squareList = [
    ["a8","b8","c8","d8","e8","f8","g8","h8"],
    ["a7","b7","c7","d7","e7","f7","g7","h7"],
    ["a6","b6","c6","d6","e6","f6","g6","h6"],
    ["a5","b5","c5","d5","e5","f5","g5","h5"],
    ["a4","b4","c4","d4","e4","f4","g4","h4"],
    ["a3","b3","c3","d3","e3","f3","g3","h3"],
    ["a2","b2","c2","d2","e2","f2","g2","h2"],
    ["a1","b1","c1","d1","e1","f1","g1","h1"],
  ];

  HashMap board = new HashMap<String, String>();

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack( 
          children: <Widget>[
            Container(
              child: new Center(child: Image.asset("assets/chess_board.png", fit: BoxFit.cover,)),
            ),
            //Overlaying draggables/ dragTargets onto the squares
            Center(
              child: Container(
                child: buildChessBoard(),
              ),
            )
          ],
      )
    );
  }

  void initializeBoard() {

    for(int i = 8; i >= 1; i--) {
      for(int j = 97; j <= 104; j++) {
        String ch = String.fromCharCode(j)+'$i';
        board[ch] = " ";
      }
    }

    setState(() {
    //Placing White Pieces
    board['a1'] = board['h1']= "R";
    board['b1'] = board['g1'] = "N";
    board['c1'] = board['f1'] = "B";
    board['d1'] = "Q";
    board['e1'] = "K";

    board['a2'] = board['b2'] = board['c2'] = board['d2'] = 
    board['e2'] = board['f2'] = board['g2'] = board['h2'] = "P";

    //Placing Black Pieces
    board['a8'] = board['h8']= "r";
    board['b8'] = board['g8'] = "n";
    board['c8'] = board['f8'] = "b";
    board['d8'] = "q";
    board['e8'] = "k";
    board['a7'] = board['b7'] = board['c7'] = board['d7'] = 
    board['e7'] = board['f7'] = board['g7'] = board['h7'] = "p";
    });
  }

  Widget buildChessBoard() {
    return Container(
      height: 350,
      child: Column(
            children: squareList.map((row) {
                return buildRow(row,);
                }).toList()   
      )
    );
  }

  Widget buildRow(List<String> children) {
    return Expanded(
      flex: 1,
      child: Row(
        children: children.map((squareName) => getImage(squareName)).toList()
      ),
    );
  }

  Widget getImage(String squareName) {
    return Expanded(
      child: DragTarget<List>(builder: (context, accepted, rejected) {
              return Draggable<List>(
                  child: mapImages(squareName),
                  feedback: mapImages(squareName),
                  onDragCompleted: () {},
                  data: [
                    squareName,
                  ],
                );
        }, onWillAccept: (willAccept) {
          return true;
        }, onAccept: (List moveInfo) {
          String from = moveInfo[0];
          String to = squareName;
          print("MOVING: $from to $to" );
          refreshBoard(from, to);
        }),
      );
  }

  void refreshBoard(String from, String to) {
    String move= from + to;
    getPositionString(move);
    setState(() {
      board[to] = board[from];
      board[from] = " ";
    });
    print("refreshing: $from and $to"); 
  }

  Widget mapImages(String squareName) {
    board.putIfAbsent(squareName, () => " ");
    String p = board[squareName];
    var size = 6.0;
    Widget imageToDisplay = Container();
    switch (p) {
      case "P":
        imageToDisplay = WhitePawn(size: size);
        break;
      case "R":
        imageToDisplay = WhiteRook(size: size);
        break;
      case "N":
        imageToDisplay = WhiteKnight(size: size);
        break;
      case "B":
        imageToDisplay = WhiteBishop(size: size);
        break;
      case "Q":
        imageToDisplay = WhiteQueen(size: size);
        break;
      case "K":
        imageToDisplay = WhiteKing(size: size);
        break;
      case "p":
        imageToDisplay = BlackPawn(size: size);
        break;
      case "r":
        imageToDisplay = BlackRook(size: size);
        break;
      case "n":
        imageToDisplay = BlackKnight(size: size);
        break;
      case "b":
        imageToDisplay = BlackBishop(size: size);
        break;
      case "q":
        imageToDisplay = BlackQueen(size: size);
        break;
      case "k":
        imageToDisplay = BlackKing(size: size);
        break;
      case "p":
        imageToDisplay = BlackPawn(size: size);
        break;
    }
    return imageToDisplay; 
  }

  String getPositionString(String move) {
    String str = "", s = "";
    print('PRINTING POSITIONS');
    for(int i = 8; i >= 1; i--) {
      int count = 0;
      for(int j = 97; j <= 104; j++) {
        String ch = String.fromCharCode(j)+'$i';
        if(board[ch] == " ") {
          count += 1;
          if(j == 104) s = s + '' + "$count";
        } else {
          if(count > 0) s = s + "$count";
          s = s + board[ch];
          count = 0;
        }
      }
      s = s + "/";
    }
    String position = s.substring(0, s.length-1) + " w KQkq - 0 1"; 
    var json = jsonEncode({"position": position, "moves": move});
    makePOSTRequest(json);
    }

    void makePOSTRequest(var json) async{
      print("MAKING A POST REQUEST: ${json}");
      var url = 'http://35.200.253.0:8080/play';
      var response = await http.post(url, headers: {"Content-Type": "application/json"} ,body: json);
      print("RESPONSE: ${response.body}");
      String rsp = response.body;
      String from = rsp.substring(0,3);
      String to = rsp.substring(3);
      refreshBoardFromServer(from, to);
      buildChessBoard();
    }

    void refreshBoardFromServer(String from, String to) {
      setState(() {
      board[to] = board[from];
      board[from] = " ";
    });
    print("refreshing board from SERVER: $from and $to");
    }
}