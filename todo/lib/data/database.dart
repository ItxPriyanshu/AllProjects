import 'package:hive/hive.dart';

class ToDoDataBase{

List todoList =[];

  //reference the box
  final _mybox = Hive.box('mybox');



  void createInitialData(){
    todoList= [["Sample task, slide left to delete",false],];
  }


  void loadData(){
    todoList = _mybox.get("TODOLIST");
  }


  void updateDataBase(){
    _mybox.put("TODOLIST", todoList);
  }
}