import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoTile extends StatelessWidget {
  final String taskname;
  final bool taskcomplete;
  Function(bool?)? onChanged;

  Function(BuildContext)? deleteFuntion;

  TodoTile({
    super.key,
    required this.taskname,
    required this.taskcomplete,
    required this.onChanged,
    required this.deleteFuntion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Slidable(
        startActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFuntion,
              icon: Icons.delete,
              backgroundColor: const Color.fromARGB(255, 204, 203, 203),
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          height: 65,
          padding: EdgeInsets.all(23),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              //task name
              Checkbox(
                value: taskcomplete,
                onChanged: onChanged,
                activeColor: Colors.black,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    taskname,
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'JuliusSansOne',
                      decoration: taskcomplete
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
