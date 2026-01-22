import 'package:dropnote/DateTime/date_time_helper.dart';
import 'package:dropnote/models/expense_item.dart';
import 'package:flutter_riverpod/legacy.dart';


class ExpenseDataNotifier extends StateNotifier<List<ExpenseItem>> {
  ExpenseDataNotifier(): super([]);

//List of all expenses
List<ExpenseItem> overallExpenseList=[];


//get expense list//
List<ExpenseItem> getExpenseList(){
  return state;
}

//add new expense//
void addNewExpense(ExpenseItem NewExpense){
  state = [...state,NewExpense];
}

//remove or delete expense//
void removeExpense(ExpenseItem expense){
  state = state.where((e)=>e!=expense).toList();
}

//get weelday//
String getDayName(DateTime dateTime){
  switch (dateTime.weekday) {
    case 1:
      return "Mon";
      case 2:
      return "Tue";
      case 3:
      return "Wed";
      case 4:
      return "Thu";
      case 5:
      return "Fri";
      case 6:
      return "Sat";
      case 7:
      return "Sun";
    default:
    return "";
  }
}


//get the date for the start of the week//
DateTime startOfWeekDate(){
  DateTime? startOfWeek;
  DateTime today = DateTime.now();

  for(int i =0;i<7;i++){
    if(getDayName(today.subtract(Duration(days: i)))=='Sun'){
      startOfWeek = today.subtract(Duration(days: i));
    }
  }
  return startOfWeek!;
}


//expense summary//
Map<String,double> calculateDailyExpenseSummary(){
  Map<String,double> dailyExpenseSummary = {}; //empty map

  /*
  23052025:345.5 
  like this 
   */
  for(var expense in overallExpenseList){
    String date = convertDateTimeToString(expense.dateTime);
    double amount = double.parse(expense.amount);
//check for same day if exist add the amount to existing amount
    if(dailyExpenseSummary.containsKey(date)){
      double currentAmount = dailyExpenseSummary[date]!;
      currentAmount+= amount;
      dailyExpenseSummary[date] = currentAmount;
    }else{
      // dailyExpenseSummary.addAll({date: amount});
      dailyExpenseSummary[date] = amount;

      //the above two line do the same thing add amount while creating a new date
      //for multiple creation or insertion use addAll(MAP inbuilt Function) method and if only 1
      //entry is there then use the second method
    }
  }
  return dailyExpenseSummary;
}

}