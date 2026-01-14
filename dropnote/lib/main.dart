import 'package:dropnote/auth/login.dart';
import 'package:dropnote/auth/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360.0, 800.0),
      minTextAdapt: true,

      child: MaterialApp(

        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.black),
      ),
      home: const SignUp(),
    ),
    );
     
  }
}
