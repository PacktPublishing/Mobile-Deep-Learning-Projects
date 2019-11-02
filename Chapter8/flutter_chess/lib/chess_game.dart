import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessGame extends StatefulWidget {
  
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
var size= 200;

  @override
  _ChessGameState createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {

  HashMap board = new HashMap<String, String>();

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
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
        ),
      )
    );
  }

  void initializeBoard() {

    setState(() {

    //Placing White Pieces
    board['a1'] = board['h1']= "WR";
    board['b1'] = board['g1'] = "WK";
    board['c1'] = board['f1'] = "WB";
    board['d1'] = "WQ";
    board['e1'] = "WK";

    board['a2'] = board['b2'] = board['c2'] = board['d2'] = 
    board['e2'] = board['f2'] = board['g2'] = board['h2'] = "WP";

    //Placing Black Pieces
    board['a8'] = board['h8']= "BR";
    board['b8'] = board['g8'] = "BK";
    board['c8'] = board['f8'] = "BB";
    board['d8'] = "BQ";
    board['e8'] = "BK";

    board['a7'] = board['b7'] = board['c7'] = board['d7'] = 
    board['e7'] = board['f7'] = board['g7'] = board['h7'] = "BP";
    });

  }


  Widget buildChessBoard() {
    return Container(
      height: 350,
      child: Column(
            children: widget.squareList.map((row) {
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
          refreshBoard(from, to);
        }),
      );
  }

  void refreshBoard(String from, String to) {
    setState(() {
      board[to] = board[from];
      board[from] = " ";
    });
    print("refreshing: $from and $to");
    //buildChessBoard();
  }

  Widget mapImages(String squareName) {
    board.putIfAbsent(squareName, () => " ");
    String p = board[squareName];
    var size = 6.0;
    Widget imageToDisplay = Container();
    switch (p) {
      case "WP":
        imageToDisplay = WhitePawn(size: size);
        break;
      case "WR":
        imageToDisplay = WhiteRook(size: size);
        break;
      case "WN":
        imageToDisplay = WhiteKnight(size: size);
        break;
      case "WB":
        imageToDisplay = WhiteBishop(size: size);
        break;
      case "WQ":
        imageToDisplay = WhiteQueen(size: size);
        break;
      case "WK":
        imageToDisplay = WhiteKing(size: size);
        break;
      case "BP":
        imageToDisplay = BlackPawn(size: size);
        break;
      case "BR":
        imageToDisplay = BlackRook(size: size);
        break;
      case "BN":
        imageToDisplay = BlackKnight(size: size);
        break;
      case "BB":
        imageToDisplay = BlackBishop(size: size);
        break;
      case "BQ":
        imageToDisplay = BlackQueen(size: size);
        break;
      case "BK":
        imageToDisplay = BlackKing(size: size);
        break;
      case "BP":
        imageToDisplay = BlackPawn(size: size);
        break;
      case "WP":
        imageToDisplay = WhitePawn(size: size);
    }
    return imageToDisplay; 
  }
}