import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/utils/utils.dart';

class GameMethods {
  void checkWinner(BuildContext context, IO.Socket socketClient) {
    final roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    String winner = '';
    final board = roomDataProvider.displayElements;

    // Rows
    if (board[0] == board[1] && board[0] == board[2] && board[0] != '') {
      winner = board[0];
    } else if (board[3] == board[4] &&
        board[3] == board[5] &&
        board[3] != '') {
      winner = board[3];
    } else if (board[6] == board[7] &&
        board[6] == board[8] &&
        board[6] != '') {
      winner = board[6];
    }

    // Columns
    else if (board[0] == board[3] &&
        board[0] == board[6] &&
        board[0] != '') {
      winner = board[0];
    } else if (board[1] == board[4] &&
        board[1] == board[7] &&
        board[1] != '') {
      winner = board[1];
    } else if (board[2] == board[5] &&
        board[2] == board[8] &&
        board[2] != '') {
      winner = board[2];
    }

    // Diagonals
    else if (board[0] == board[4] &&
        board[0] == board[8] &&
        board[0] != '') {
      winner = board[0];
    } else if (board[2] == board[4] &&
        board[2] == board[6] &&
        board[2] != '') {
      winner = board[2];
    }

    // Draw
    else if (roomDataProvider.filledBoxes == 9) {
      winner = '';
      showGameDialog(context, 'DRAW');
      return;
    }

    // Emit winner
    if (winner.isNotEmpty && socketClient.connected) {
      if (roomDataProvider.player1?.playerType == winner) {
      showGameDialog(context, '${roomDataProvider.player1!.nickname} WON');

        socketClient.emit('winner', {
          'winnerSocketId': roomDataProvider.player1!.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
      } else if (roomDataProvider.player2?.playerType == winner) {
      showGameDialog(context, '${roomDataProvider.player2!.nickname} WON');

        socketClient.emit('winner', {
          'winnerSocketId': roomDataProvider.player2!.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
      }
    }
  }

}
