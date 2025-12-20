import 'package:flutter/material.dart';
import 'package:tictactoe/resources/socket_methods.dart';
import 'package:tictactoe/widgets/custom_botton.dart';
import 'package:tictactoe/widgets/custom_text.dart';
import 'package:tictactoe/widgets/custom_textfield.dart';

class Createroomscreen extends StatefulWidget {
  static String routeName = '/create-room';

  const Createroomscreen({super.key});

  @override
  State<Createroomscreen> createState() => _CreateroomscreenState();
}

class _CreateroomscreenState extends State<Createroomscreen> {

  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketmethods = SocketMethods();

    @override
    void initState(){
      super.initState();
      _socketmethods.createRoomSuccessListener(context);
    }



  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
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
              text: 'Create Room',
              fontSize: 70,
            ),
            SizedBox(height: size.height * 0.08),
            CustomTextfield(
              controller: _nameController,
              hintText: 'Enter your nick name',
            ),
            SizedBox(height: size.height * 0.045),
            CustomButton(onTap: () => _socketmethods.createRoom(_nameController.text), text: 'Create'),
          ],
        ),
      ),
    );
  }
}
