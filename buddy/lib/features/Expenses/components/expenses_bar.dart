import 'package:dropnote/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensesBar extends ConsumerWidget {
  const ExpensesBar({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final weeklyData = ref.watch(weeklyExpenseProvider);
    final maxValue = weeklyData.reduce((a,b)=>a>b ? a:b);
    return BarChart(BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
        )
      ),
      maxY: maxValue == 0 ? 100:maxValue+50,
      barGroups: List.generate(7,(index){
        return BarChartGroupData(x: index,
        barRods: [
          BarChartRodData(toY: weeklyData[index],
          width: 20,
          borderRadius: BorderRadius.circular(6),
        
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxValue+50,
            color: const Color.fromARGB(56, 158, 158, 158),
          ),
          color: Colors.greenAccent
          )
        ]
        );
      }),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false),),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
        getTitlesWidget: (value, meta) {
          const days = [
            'Sun','Mon','Tue','Wed','Thu','Fri','Sat'
          ];
          return Text(days[value.toInt()]);
        },),
        
        ),
        
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false)
    ));
  }
}