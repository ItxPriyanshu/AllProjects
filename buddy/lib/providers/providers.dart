import 'package:dropnote/DateTime/date_time_helper.dart';
import 'package:dropnote/data/expense_data.dart';
import 'package:dropnote/data/schedule_builder.dart';
import 'package:dropnote/data/todo_data.dart';
import 'package:dropnote/models/expense_item.dart';
import 'package:dropnote/models/schedule_cell.dart';
import 'package:dropnote/models/todo_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final expenseProvider = StateNotifierProvider<ExpenseDataNotifier,List<ExpenseItem>>((ref) =>ExpenseDataNotifier());

final dailyExpenseSummaryProvider = Provider<Map<String,double>>((ref){
  ref.watch(expenseProvider);
  return ref.read(expenseProvider.notifier).calculateDailyExpenseSummary();
});

final todayTotalExpenseProvider = Provider<double>((ref) {
  final summaryMap = ref.watch(dailyExpenseSummaryProvider);
  final todayKey = convertDateTimeToString(DateTime.now());
  return summaryMap[todayKey] ?? 0.0;
});

final todoProvider = StateNotifierProvider<TodoDataNotifier,List<TodoModel>>((ref) =>TodoDataNotifier());

final bottomNavIndexProvider = StateProvider<int>((ref)=>1);

final scheduleProvider = StateNotifierProvider<ScheduleNotifier,List<ScheduleCell?>>((ref)=> ScheduleNotifier());


final weeklyExpenseProvider = Provider<List<double>>((ref){
final dailySummary = ref.watch(dailyExpenseSummaryProvider);
final startOfWeek = ref.read(expenseProvider.notifier).startOfWeekDate();
List<double> weeklyTotals = List.filled(7, 0.0);

for(int i =0;i<7;i++){
  final day = startOfWeek.add(Duration(days: i));
  final key = convertDateTimeToString(day);

  if(dailySummary.containsKey(key)){
    weeklyTotals[i] = dailySummary[key]!;
  }
}
  return weeklyTotals;
}
);