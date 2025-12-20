import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:my_calculator/components.dart';


class HomeScreen extends StatefulWidget {
  static const String id ='home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var userInput='';
  var answer='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(userInput.toString(),style: TextStyle(fontSize: 30,color: Colors.white),),
                      Text(answer.toString(),style: TextStyle(fontSize: 30,color: Colors.white),),
                  
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                  children: [
                  Button(title: 'AC',onpress: (){
                    userInput='';
                    answer='';
                    setState(() {});
                  },),
                  Button(title: '+/-',onpress: (){
                    userInput+='+/-';
                    setState(() {});
                  },),
                  Button(title: '%',onpress: (){
                    userInput+='%';
                    setState(() {});
                  },),
                  Button(title: '/',color: Colors.orange,onpress: (){
                    userInput+='/';
                    setState(() {});
                  },),
                ],),
                Row(
                  children: [
                  Button(title: '7',onpress: (){
                    userInput+='7';
                    setState(() {});
                  },),
                  Button(title: '8',onpress: (){
                    userInput+='8';
                    setState(() {});
                  },),
                  Button(title: '9',onpress: (){
                    userInput+='9';
                    setState(() {});
                  },),
                  Button(title: 'x',color: Colors.orange,onpress: (){
                    userInput+='x';
                    setState(() {});
                  },),
                ],),
                Row(
                  children: [
                  Button(title: '4.',onpress: (){
                    userInput+='4';
                    setState(() {});
                  },),
                  Button(title: '5',onpress: (){
                    userInput+='5';
                    setState(() {});
                  },),
                  Button(title: '6',onpress: (){
                    userInput+='6';
                    setState(() {});
                  },),
                  Button(title: '-',color: Colors.orange,onpress: (){
                    userInput+='-';
                    setState(() {});
                  },),
                ],),
                Row(
                  children: [
                  Button(title: '1',onpress: (){
                    userInput+='1';
                    setState(() {});
                  },),
                  Button(title: '2',onpress: (){
                    userInput+='2';
                    setState(() {});
                  },),
                  Button(title: '3',onpress: (){
                    userInput+='3';
                    setState(() {});
                  },),
                  Button(title: '+',color: Colors.orange,onpress: (){
                    userInput+='+';
                    setState(() {});
                  },),
                ],),
                 Row(
                  children: [
                  Button(title: '0',onpress: (){
                          userInput+='0';
                          setState(() {});
                  },),
                  Button(title: '.',onpress: (){
                          userInput+='.';
                          setState(() {});
                  },),
                  Button(title: 'DEL',onpress: (){
                          userInput=userInput.substring(0,userInput.length-1);
                          setState(() {});
                  },),
                  Button(title: '=',color: Colors.orange,onpress: (){
                          equalPress();
                          setState(() {});
                  },),
                ],),
                  ],
                ),
              )
              
            ],
          ),
        ),
      )
    );



  }


  void equalPress(){
    userInput=userInput.replaceAll('x', '*');
    GrammarParser p=GrammarParser();
    Expression expression=p.parse(userInput);
    ContextModel contextModel = ContextModel();
    double eval = expression.evaluate(EvaluationType.REAL, contextModel);
    answer=eval.toString();


  }
}