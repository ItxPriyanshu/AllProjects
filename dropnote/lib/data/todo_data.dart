import 'package:dropnote/models/todo_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class TodoDataNotifier extends StateNotifier<List<TodoModel>>{
   TodoDataNotifier(): super([]);
  

  List<TodoModel> overallTodoList= [];


  //overall todo list 
  List<TodoModel> getOverallTodoList(){
  return state;
}

//add todo
void addNewTodo(TodoModel newTodo){
  state = [...state,newTodo];
}

//remove todo
void removeTodo(TodoModel todo){
  state = state.where((e)=>e!=todo).toList();
}

void toggleCheckDone(int index){
  final updatedTodo = state[index].copyWith(isDone: !state[index].isDone);
  final newList = [...state];
  newList[index] = updatedTodo;
  state = newList;
}
}