import 'package:flutter/material.dart';

class RoomDataProvider extends ChangeNotifier {
  // Full room object (contains _id, players, turn, etc.)
  Map<String, dynamic> _roomData = {};

  // Getter
  Map<String, dynamic> get roomData => _roomData;

  // Update whole room data (CreateRoomSuccess, joinRoomSuccess, updatePlayers)
  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;
    notifyListeners();
  }
}
