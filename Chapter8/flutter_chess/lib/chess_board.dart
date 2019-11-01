import 'package:flutter/material.dart';
import 'chess_game.dart';
import 'package:scoped_model/scoped_model.dart';
import 'chess_board_controller.dart';
import 'board_model.dart';

var whiteSquareList = [
  ["a8","b8","c8","d8","e8","f8","g8","h8"],
  ["a7","b7","c7","d7","e7","f7","g7","h7"],
  ["a6","b6","c6","d6","e6","f6","g6","h6"],
  ["a5","b5","c5","d5","e5","f5","g5","h5"],
  ["a4","b4","c4","d4","e4","f4","g4","h4"],
  ["a3","b3","c3","d3","e3","f3","g3","h3"],
  ["a2","b2","c2","d2","e2","f2","g2","h2"],
  ["a1","b1","c1","d1","e1","f1","g1","h1"],
];

class ChessBoard extends StatefulWidget {
  final double size;

  /// Callback for when move is made
  final MoveCallback onMove;

  /// Callback for when a player is checkmated
  // final CheckMateCallback onCheckMate;

  // /// Callback for when a player is in check
  // final CheckCallback onCheck;

  /// Callback for when the game is a draw
  final VoidCallback onDraw;

  /// A boolean which notes if white board side is towards users
  final bool whiteSideTowardsUser;

  /// A controller to programmatically control the chess board
  final ChessBoardController chessBoardController;

  /// A boolean which checks if the user should be allowed to make moves
  final bool enableUserMoves;

  ChessBoard({
    this.size = 200.0,
    this.whiteSideTowardsUser = true,
    @required this.onMove,
    // @required this.onCheckMate,
    // @required this.onCheck,
    @required this.onDraw,
    this.chessBoardController,
    this.enableUserMoves = true,
  });


  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {

    @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: BoardModel(
        widget.size,
        widget.onMove,
        // widget.onCheckMate,
        // widget.onCheck,
        // widget.onDraw,
        widget.whiteSideTowardsUser,
        widget.chessBoardController,
        widget.enableUserMoves,
      ),
      child: Container(
        height: widget.size,
        width: widget.size,
        child: Stack( 
          children: <Widget>[
            Container(
              height: widget.size,
              width: widget.size,
              child: new Center(child: Image.asset("assets/chess_board.png", fit: BoxFit.cover,)),
            ),
            //Overlaying draggables/ dragTargets onto the squares
            Center(
              child: Container(
                height: widget.size,
                width: widget.size,
                child: buildChessBoard(),
              ),
            )
          ],
        ),
      ),
    );
  }

    Widget buildChessBoard() {
    return Container(
      height: 350,
      child: Column(
            children: whiteSquareList.map((row) {
                return buildRow(
                  row,
                );
              }).toList()   
      )
    );
  }

  Widget buildRow(List<String> children) {
    return Expanded(
      flex: 1,
      child: Row(
        children: children.map((squareName) => ChessGame(squareName: squareName)).toList()
      ),
    );
  }
}