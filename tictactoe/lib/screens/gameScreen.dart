import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/socket_methods.dart';
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
    _socketMethods.updateRoomListener(context);
    _socketMethods.updatePlayersStateListener(context);
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomDataProvider>(context);
  final roomData = roomProvider.roomData;

  final players = roomData['players'] as List<dynamic>? ?? [];

    return Scaffold(
      body: players.length < 2
      ? const WaitingLobby()
      : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ROOM ID',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              roomData['_id'], // ✅ ONLY THIS IS THE ROOM ID
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
