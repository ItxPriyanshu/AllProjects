import 'package:dropnote/data/expense_data.dart';
import 'package:dropnote/models/expense_item.dart';
import 'package:flutter_riverpod/legacy.dart';

final expenseProvider = StateNotifierProvider<ExpenseDataNotifier,List<ExpenseItem>>((ref) =>ExpenseDataNotifier());