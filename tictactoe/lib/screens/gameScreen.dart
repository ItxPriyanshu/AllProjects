import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/socket_methods.dart';
import 'package:tictactoe/views/scoreboard.dart';
import 'package:tictactoe/views/tictactoeboard.dart';
import 'package:tictactoe/views/waiting_lobby.dart';

class Gamescreen extends StatefulWidget {
  static String routeName = '/game';
  const Gamescreen({super.key});

  @override
  State<Gamescreen> createState() => _GamescreenState();
}

class _GamescreenState extends State<Gamescreen> {
  final SocketMethods _socketMethods = SocketMethods();

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final roomProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    _socketMethods.updateRoomListener(roomProvider);
    _socketMethods.updatePlayersListener(roomProvider);
  });
}

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomDataProvider>(context);
  final roomData = roomProvider.roomData;

  final players = roomData['players'] as List<dynamic>? ?? [];

    return Scaffold(
      body: players.length < 2
      ? const WaitingLobby()
      :SafeArea(child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Scoreboard(),
          const Tictactoeboard(),
        ],
      )),
    );
  }
}
