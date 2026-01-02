import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    final players = roomDataProvider.roomData['players'];
    debugPrint('ROOM DATA: ${roomDataProvider.roomData}');
    debugPrint('PLAYERS: $players');



    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(padding: EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(players[0]['nickname'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
          Text(players[0]['points'].toString(),style: TextStyle(fontSize: 20,color: Colors.white),),
        ],
        ),),
        Padding(padding: EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Text(players[1]['nickname'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
              Text(players[1]['points'].toString(),style: TextStyle(fontSize: 20,color: Colors.white),),
        ],
        ),),

      ],
    );
  }
}