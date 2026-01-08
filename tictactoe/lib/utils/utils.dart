import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/socket_methods.dart';

void showSnackBar(BuildContext context,String content){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content),)
  );
}



void showGameDialog(BuildContext context,String text){
  showDialog(
    barrierDismissible: false,
    context: context, builder: (context){
    return AlertDialog(
      title: Text(text),
      actions: [TextButton(
  onPressed: () {
    final roomProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    SocketMethods().playAgain(
      roomProvider.roomData['_id'],
    );

    Navigator.pop(context);
  },
  child: const Text('Play Again'),
),
],
    );
  });
}