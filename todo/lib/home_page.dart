import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/data/database.dart';
import 'package:todo/dialoge_box.dart';
import 'package:todo/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
 
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //reference  the hive box

  final _mybox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  final _controller = TextEditingController();

  

  @override
  void initState() {
    if (_mybox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  //save new task
  void saveNew() {
    setState(() {
      db.todoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.pop(context);
    db.updateDataBase();
  }

  //checkbox was tapped
  void checkBoxChanged(bool? vlaue, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateDataBase();
  }

  //delete task
  void deleteTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
      
    });
    db.updateDataBase();
  }

  //create new task
  void createnewtask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogeBox(
          controller: _controller,
          onSave: saveNew,
          onCancel: () => Navigator.pop(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        title: Text('To Do',style: TextStyle(color: Colors.white,fontSize: 30,fontFamily: 'JuliusSansOne'),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 54, 54, 54),
      ),

      body: ListView.builder(
        itemCount: db.todoList.length,
        itemBuilder: (context, index) {
          return TodoTile(
            taskname: db.todoList[index][0],
            taskcomplete: db.todoList[index][1],
            onChanged: (value) {
              checkBoxChanged(value, index);
            },
            deleteFuntion: (context) => deleteTask(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createnewtask,
        backgroundColor: Colors.white,
        elevation: 5,
        splashColor: Colors.grey,
        shape: CircleBorder(),
        child: Icon(Icons.add),
      ),
    );
  }
}
