import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/game_methods.dart';
import 'package:tictactoe/resources/socket_client.dart';
import 'package:tictactoe/utils/utils.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  // ================= EMITS =================
  void createRoom(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {'nickname': nickname});
    }
  }

  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit('joinRoom', {'nickname': nickname, 'roomId': roomId});
    }
  }

  void tapGrid(int index, String roomId, List<String> displayElements) {
    if (displayElements[index] == '') {
      _socketClient.emit('tap', {'index': index, 'roomId': roomId});
    }
  }

  // ================= LISTENERS =================

  void createRoomSuccessListener(
    void Function(Map<String, dynamic> room) onSuccess,
  ) {
    _socketClient.off('CreateRoomSuccess');
    _socketClient.on('CreateRoomSuccess', (room) {
      onSuccess(Map<String, dynamic>.from(room));
    });
  }

  void joinRoomSuccessListener(
    void Function(Map<String, dynamic> room) onSuccess,
  ) {
    _socketClient.off('joinRoomSuccess');
    _socketClient.on('joinRoomSuccess', (room) {
      onSuccess(Map<String, dynamic>.from(room));
    });
  }

  void updatePlayersListener(RoomDataProvider roomProvider) {
    _socketClient.off('updatePlayers');
    _socketClient.on('updatePlayers', (players) {
      roomProvider.updateRoomData({
        ...roomProvider.roomData,
        'players': players,
      });
    });
  }

  void updateRoomListener(RoomDataProvider roomProvider) {
    _socketClient.off('updateRoom');
    _socketClient.on('updateRoom', (room) {
      roomProvider.updateRoomData(Map<String, dynamic>.from(room));
    });
  }

  void errorListener(void Function(String msg) onError) {
    _socketClient.off('errorOccured');
    _socketClient.on('errorOccured', (err) {
      onError(err.toString());
    });
  }

void tappedListener(
  BuildContext context,
  RoomDataProvider roomProvider,
) {
  _socketClient.off('tapped');
  _socketClient.on('tapped', (data) {
    roomProvider.updateDisplayElements(
      data['index'],
      data['choice'],
    );

    roomProvider.updateRoomData(
      Map<String, dynamic>.from(data['room']),
    );

    //  context is now available
    GameMethods().checkWinner(context, _socketClient);
  });
}

  void removeTappedListener() {
    _socketClient.off('tapped');
  }

  void pointIncreaseListener(BuildContext context){
    _socketClient.on('pointIncrease',(playerData){
      var roomDataProvider = Provider.of<RoomDataProvider>(context,listen: false);
    if(playerData['socketID']== roomDataProvider.player1?.socketID){
      roomDataProvider.updatePlayer1(playerData);
    }else{roomDataProvider.updatePlayer2(playerData);}
    }
    );
  }


  void endGameListener(BuildContext context){
    _socketClient.on('endGame',(playerData){
      showGameDialog(context, '${playerData['nickname']} won the game! ');
      Navigator.popUntil(context, (route)=>false);
    });
  }

  void playAgain(String roomId) {
  _socketClient.emit('playAgain', {
    'roomId': roomId,
  });
}


void resetBoardListener(RoomDataProvider roomProvider) {
  _socketClient.off('resetBoard');
  _socketClient.on('resetBoard', (room) {
    roomProvider.resetBoard();
    roomProvider.updateRoomData(Map<String, dynamic>.from(room));
  });
}

}
