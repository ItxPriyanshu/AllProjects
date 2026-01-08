import 'package:flutter/material.dart';
import 'package:tictactoe/model/player.dart';

class RoomDataProvider extends ChangeNotifier {
  Map<String, dynamic> _roomData = {};

  Player? _player1;
  Player? _player2;

  List<String> _displayElement = List.filled(9, '');
  int _filledBoxes = 0;

  // Getters
  Map<String, dynamic> get roomData => _roomData;
  Player? get player1 => _player1;
  Player? get player2 => _player2;
  List<String> get displayElements => _displayElement;
  int get filledBoxes => _filledBoxes;

  // Update room data from socket
  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;

    if (data['players'] != null && data['players'].length >= 2) {
      _player1 = Player.fromMap(data['players'][0]);
      _player2 = Player.fromMap(data['players'][1]);
    }

    notifyListeners();
  }

  void updateDisplayElements(int index, String choice) {
    if (_displayElement[index].isNotEmpty) return;
    _displayElement[index] = choice;
    _filledBoxes++;
    notifyListeners();
  }

  void setFilledBoxesTo0(){
    _filledBoxes =0;
    notifyListeners();

  }

  void resetBoard() {
    _displayElement = List.filled(9, '');
    _filledBoxes = 0;
    notifyListeners();
  }

  void updatePlayer1(Map<String, dynamic> playerData) {
  _player1 = Player.fromMap(playerData);
  notifyListeners();
}

void updatePlayer2(Map<String, dynamic> playerData) {
  _player2 = Player.fromMap(playerData);
  notifyListeners();
}

}
