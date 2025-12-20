import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/socket_client.dart';
import 'package:tictactoe/screens/gameScreen.dart';
import 'package:tictactoe/utils/utils.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  // ================= EMITS =================

  void createRoom(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {'nickname': nickname});
    }
  }

  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit(
        'joinRoom',
        {'nickname': nickname, 'roomId': roomId},
      );
    }
  }

  // ================= LISTENERS =================

  void createRoomSuccessListener(BuildContext context) {
    _socketClient.off('CreateRoomSuccess');

    _socketClient.on('CreateRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(
        context,
        listen: false,
      ).updateRoomData(
        Map<String, dynamic>.from(room),
      );

      Navigator.pushNamed(context, Gamescreen.routeName);
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.off('joinRoomSuccess');

    _socketClient.on('joinRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(
        context,
        listen: false,
      ).updateRoomData(
        Map<String, dynamic>.from(room),
      );

      Navigator.pushNamed(context, Gamescreen.routeName);
    });
  }

void updatePlayersStateListener(BuildContext context) {
  _socketClient.off('updatePlayers');

  _socketClient.on('updatePlayers', (playersData) {
    final roomProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    roomProvider.updateRoomData({
      ...roomProvider.roomData,
      'players': playersData,
    });
  });
}


void updateRoomListener(BuildContext context){
  _socketClient.on('updateRoom',(data){
    Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(data);
  });
}

  void errorOccuredListener(BuildContext context) {
    _socketClient.off('errorOccured');

    _socketClient.on('errorOccured', (error) {
      showSnackBar(context, error);
    });
  }
}
