import 'package:flutter/material.dart';
import "package:chess/chess.dart" as chess;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'board_model.dart';


class ChessGame extends StatelessWidget {
  
  final squareName;
  ChessGame({this.squareName});
  chess.Chess game = chess.Chess();
  
    
@override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BoardModel>(builder: (context, _, model) {
      return Expanded(
        flex: 1,
        child: DragTarget(builder: (context, accepted, rejected) {
          return model.game.get(squareName) != null
              ? Draggable(
                  child: _getImageToDisplay(size: model.size / 8, model: model),
                  feedback: _getImageToDisplay(
                      size: (1.2 * (model.size / 8)), model: model),
                  onDragCompleted: () {},
                  data: [
                    squareName,
                    model.game.get(squareName).type.toUpperCase(),
                    model.game.get(squareName).color,
                  ],
                )
              : Container();
        }, onWillAccept: (willAccept) {
          return model.enableUserMoves ? true : false;
        }, onAccept: (List moveInfo) {
          print('$moveInfo, $squareName');
          // A way to check if move occurred.
          chess.Color moveColor = model.game.turn;
            model.game.move({"from": moveInfo[0], "to": squareName});
          
          if (model.game.turn != moveColor) {
            model.onMove(
                moveInfo[1] == "P" ? squareName : moveInfo[1] + squareName);
          }
          model.refreshBoard();
        }),
      );
    });
  }

  Widget _getImageToDisplay({double size, BoardModel model}) {
    Widget imageToDisplay = Container();

    if (model.game.get(squareName) == null) {
      return Container();
    }

    String piece = model.game
            .get(squareName)
            .color
            .toString()
            .substring(0, 1)
            .toUpperCase() +
        model.game.get(squareName).type.toUpperCase();

    switch (piece) {
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
      default:
        imageToDisplay = WhitePawn(size: size);
    }

    return imageToDisplay;
  }
}