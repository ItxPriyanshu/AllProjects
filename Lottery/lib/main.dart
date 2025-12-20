import 'package:flutter/material.dart';
import 'dart:math';


void main() {
  runApp(const Lottery());
}

class Lottery extends StatefulWidget {
  const Lottery({super.key});

  @override
  State<Lottery> createState() => _LotteryState();
}

class _LotteryState extends State<Lottery> {

  Random random=Random();
  int x = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(
            child: Text('FunLottery', style: TextStyle(fontSize: 25)),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 173, 173),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Your Lottery Number is: 7",
                style: TextStyle(fontSize: 20),
              ),  
            ),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 20,right: 20),
              child: Container(
                height: 250,
                width: x==7 ? 300:null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 236, 236, 236),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: x==7 ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Icon(Icons.done_all,color: Colors.blue,),
                    SizedBox(height: 10),
                    Text('HURRAYY!! \n You have won the lottery \n Your number is: $x' ,textAlign: TextAlign.center,)
                  ],) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Icon(Icons.error,color: Colors.red,),
                    SizedBox(height: 10),
                    Text('Better luck next time, your number is $x\n try again' ,textAlign: TextAlign.center,)
                  ],),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {});
            x=random.nextInt(10);
            print(x);
          },
          backgroundColor: Color.fromARGB(255, 255, 173, 173),
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}
