import 'package:flutter/material.dart';
import 'package:tictactoe/resources/socket_methods.dart';
import 'package:tictactoe/widgets/custom_botton.dart';
import 'package:tictactoe/widgets/custom_text.dart';
import 'package:tictactoe/widgets/custom_textfield.dart';

class Joinroomscreen extends StatefulWidget {
  static String routeName = '/join-room';
  const Joinroomscreen({super.key});

  @override
  State<Joinroomscreen> createState() => _JoinroomscreenState();
}

class _JoinroomscreenState extends State<Joinroomscreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();
  final SocketMethods _SocketMethods = SocketMethods();

@override
void initState(){
  super.initState();
  _SocketMethods.joinRoomSuccessListener(context);
  _SocketMethods.errorOccuredListener(context);
  _SocketMethods.updatePlayersStateListener(context);
}

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _gameIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomText(
              shadows: [Shadow(blurRadius: 10, color: Colors.white)],
              text: 'Join Room',
              fontSize: 70,
            ),
            SizedBox(height: size.height * 0.08),
            CustomTextfield(
              controller: _nameController,
              hintText: 'Enter your nick name',  
            ),
            SizedBox(height: 20),

            CustomTextfield(
              controller: _gameIdController,
              hintText: 'Enter Game ID',
            ),
            SizedBox(height: size.height * 0.045),
            CustomButton(
              onTap: () => _SocketMethods.joinRoom(
                _nameController.text.trim(),
                _gameIdController.text.trim(),
              ),
              text: 'Join',
            ),
          ],
        ),
      ),
    );
    ;
  }
}
