import 'package:flutter/material.dart';
import 'package:tictactoe/responsive/responsive.dart';
import 'package:tictactoe/screens/createRoomScreen.dart';
import 'package:tictactoe/screens/joinRoomScreen.dart';
import 'package:tictactoe/widgets/custom_botton.dart';

class MainMenuScreen extends StatelessWidget {
  static String routeName = '/main-menu';

    void createRoom (BuildContext context){
      Navigator.pushNamed(context, Createroomscreen.routeName);
    }
    void joinRoom (BuildContext context){
      Navigator.pushNamed(context, Joinroomscreen.routeName);
    }

  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(onTap: () => createRoom(context), text: 'Create Room'),
            SizedBox(height: 10),
            CustomButton(onTap: () => joinRoom(context), text: 'Join Room'),
          ],
        ),
      ),
    );
  }
}
