import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Streaknstatistics extends StatefulWidget {
  const Streaknstatistics({super.key});

  @override
  State<Streaknstatistics> createState() => _StreaknstatisticsState();
}

class _StreaknstatisticsState extends State<Streaknstatistics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Performance',style: TextStyle(fontFamily: 'Barlow',fontWeight: FontWeight.w700),),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 241, 247, 255),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    backgroundColor: Colors.yellow[100],
                    radius: 40,
                    child: Lottie.asset('assets/lottie/streaklottie.json'),
                  ),
                  Text(
                    '7 Days',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Barlow',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Barlow',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'Keep up the great work! Consisency is key to mastering skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Text(
                'Subject Perforamce',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(toY: 10, color: Colors.greenAccent),
                            BarChartRodData(toY: 3, color: Colors.red),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(toY: 10, color: Colors.greenAccent),
                            BarChartRodData(toY: 12, color: Colors.red),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(toY: 10, color: Colors.greenAccent),
                            BarChartRodData(toY: 4, color: Colors.red),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Accuracy',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Subjects',
                            style: TextStyle(color: Colors.white),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text(
                                    'Maths',
                                    style: TextStyle(color: Colors.blue[700]),
                                  );
                                case 1:
                                  return Text(
                                    'Science',
                                    style: TextStyle(color: Colors.blue[700]),
                                  );
                                case 2:
                                  return Text(
                                    'Computer',
                                    style: TextStyle(color: Colors.blue[700]),
                                  );
                                default:
                                  return Text("");
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Text(
                'Overall Data',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Barlow',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
            ),

            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: 30,color: Colors.lightBlue[400]),
                        PieChartSectionData(value: 30,color: Colors.amber[300]),
                        PieChartSectionData(value: 40,color: Colors.green[400]),
                      ],
                      centerSpaceRadius: 70,
                    ),
                  ),
                ),
              ),
              
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,top: 10,),
              child: Row(children: [Container(width: 10,height: 10,color: Colors.amber,),SizedBox(width: 10,),Text("Maths",style: TextStyle(fontSize: 15,fontFamily: 'Barlow'),)],),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,top: 10,),
              child: Row(children: [Container(width: 10,height: 10,color: Colors.blue,),SizedBox(width: 10,),Text("Computer",style: TextStyle(fontSize: 15,fontFamily: 'Barlow'),)],),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30,top: 10,),
              child: Row(children: [Container(width: 10,height: 10,color: Colors.green,),SizedBox(width: 10,),Text("Science",style: TextStyle(fontSize: 15,fontFamily: 'Barlow'),)],),
            ),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
