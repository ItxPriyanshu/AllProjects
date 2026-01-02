import 'package:flutter/material.dart';

class RoomDataProvider extends ChangeNotifier {
  // Full room object (contains _id, players, turn, etc.)
  Map<String, dynamic> _roomData = {};
  List<String> _displayElement = ['','','','','','','','',''];
  int _filledBoxes = 0;

  // Getter
  Map<String, dynamic> get roomData => _roomData;
  List<String>  get displayElements=>_displayElement;

  // Update whole room data (CreateRoomSuccess, joinRoomSuccess, updatePlayers)
  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;
    notifyListeners();
  }


  void updateDisplayElements(int index,String choice){
    if (_displayElement[index] != '') return;
    _displayElement[index]=choice;
    _filledBoxes+=1;
    notifyListeners();
  }
}
