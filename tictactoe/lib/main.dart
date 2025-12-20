import 'package:flutter/material.dart';
import 'package:tictactoe/colors.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/screens/createRoomScreen.dart';
import 'package:tictactoe/screens/gameScreen.dart';
import 'package:tictactoe/screens/joinRoomScreen.dart';
import 'package:tictactoe/screens/main_menu_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context)=>RoomDataProvider(),
      
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
        ),
      routes: {
        MainMenuScreen.routeName: (context) => const MainMenuScreen(), 
        Createroomscreen.routeName: (context)=> const Createroomscreen(),
        Joinroomscreen.routeName: (context)=> const Joinroomscreen(),
        Gamescreen.routeName:(context)=> const Gamescreen(),
      },
        initialRoute: MainMenuScreen.routeName,
      ),
    );
  }
}

