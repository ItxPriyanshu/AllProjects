import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/resources/socket_methods.dart';

class Tictactoeboard extends StatefulWidget {
  const Tictactoeboard({super.key});

  @override
  State<Tictactoeboard> createState() => _TictactoeboardState();
}

class _TictactoeboardState extends State<Tictactoeboard> {
  final SocketMethods _socketMethods = SocketMethods();
  late RoomDataProvider roomProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    roomProvider = Provider.of<RoomDataProvider>(context, listen: false);
    _socketMethods.tappedListener(roomProvider);
  }

    @override
  void dispose() {
    _socketMethods.removeTappedListener(); // 🔑 REQUIRED
    super.dispose();
  }
  void tapped(int index, RoomDataProvider roomDataProvider) {
    _socketMethods.tapGrid(
      index,
      roomDataProvider.roomData['_id'],
      roomDataProvider.displayElements,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.height * 0.7, maxWidth: 500),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => tapped(index, roomDataProvider),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  roomDataProvider.displayElements[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 100,
                    shadows: [
                      Shadow(
                        blurRadius: 40,
                        color: roomDataProvider.displayElements[index] == 'O'
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
