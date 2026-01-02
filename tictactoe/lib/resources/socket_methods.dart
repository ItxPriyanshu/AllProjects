import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/socket_client.dart';

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
      _socketClient.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
      });
    }
  }

  void tapGrid(int index, String roomId, List<String> displayElements) {
    if (displayElements[index] == '') {
      _socketClient.emit('tap', {
        'index': index,
        'roomId': roomId,
      });
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

  void tappedListener(RoomDataProvider roomProvider) {
    _socketClient.off('tapped');
    _socketClient.on('tapped', (data) {
      roomProvider.updateDisplayElements(
        data['index'],
        data['choice'],
      );
      roomProvider.updateRoomData(
        Map<String, dynamic>.from(data['room']),
      );
    });
  }

  void removeTappedListener() {
    _socketClient.off('tapped');
  }
}
