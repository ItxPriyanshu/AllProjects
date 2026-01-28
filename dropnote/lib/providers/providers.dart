import 'package:dropnote/data/expense_data.dart';
import 'package:dropnote/data/schedule_builder.dart';
import 'package:dropnote/data/todo_data.dart';
import 'package:dropnote/models/expense_item.dart';
import 'package:dropnote/models/schedule_cell.dart';
import 'package:dropnote/models/todo_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final expenseProvider = StateNotifierProvider<ExpenseDataNotifier,List<ExpenseItem>>((ref) =>ExpenseDataNotifier());

final todoProvider = StateNotifierProvider<TodoDataNotifier,List<TodoModel>>((ref) =>TodoDataNotifier());

final bottomNavIndexProvider = StateProvider<int>((ref)=>1);

final scheduleProvider = StateNotifierProvider<ScheduleNotifier,List<ScheduleCell?>>((ref)=> ScheduleNotifier());
