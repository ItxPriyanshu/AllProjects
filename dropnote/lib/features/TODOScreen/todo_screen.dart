import 'dart:ffi';
import 'dart:io';

import 'package:dropnote/data/todo_data.dart';
import 'package:dropnote/features/Expenses/components/customtextfield.dart';
import 'package:dropnote/models/todo_model.dart';
import 'package:dropnote/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final TextEditingController _todocontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todolistener = ref.watch(todoProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),

        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    SizedBox(height: 140),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: todolistener.length,
                      itemBuilder: (context, index) {
                        final todo = todolistener[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: (todo.isDone)
                                    ? Colors.white.withAlpha(20)
                                    : Colors.white,
                                // const Color.fromARGB(255, 170, 157, 39),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: (todo.isDone)
                                  ? const Color.fromARGB(
                                      255,
                                      27,
                                      125,
                                      205,
                                    ).withAlpha(20)
                                  : const Color.fromARGB(255, 27, 125, 205),
                            ),

                            //List with checkbox
                            child: CheckboxListTile(
                              activeColor: Colors.green,
                              checkColor: Colors.white,
                              title: Text(
                                todo.title,
                                style: GoogleFonts.firaSans(
                                  decoration: (todo.isDone)
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              value: todo.isDone,
                              onChanged: (context) {
                                ref
                                    .read(todoProvider.notifier)
                                    .toggleCheckDone(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            //top container
            Container(
              height: 130,
              width: double.infinity,
              color: const Color.fromARGB(255, 12, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lotties/DocumentIconLottieAnimation.json',
                  ),
                  Text(
                    'ToDo',
                    style: GoogleFonts.firaSansCondensed(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        //floating action button//
        floatingActionButton: FloatingActionButton(
          splashColor: const Color.fromARGB(255, 0, 0, 0).withAlpha(100),
          backgroundColor: Color(0xFFF9C067),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5, // 50% screen
                  minChildSize: 0.3, // min 30%
                  maxChildSize: 0.9, // max 90%
                  expand: false,
                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      decoration: const BoxDecoration(
                        color: const Color.fromARGB(255, 48, 97, 188),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "Add ToDo",
                              style: GoogleFonts.firaSansCondensed(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              bottom: 8,
                              top: 8,
                            ),
                            child: expenseTextField(
                              keyboardType: TextInputType.text,
                              title: 'Add todo',
                              controller: _todocontroller,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 70,
                              vertical: 10,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              onPressed: (_todocontroller.text.length > 0)
                                  ? () {
                                      final newtodo = TodoModel(
                                        title: _todocontroller.text,
                                      );

                                      ref
                                          .read(todoProvider.notifier)
                                          .addNewTodo(newtodo);
                                      _todocontroller.clear();
                                      Navigator.pop(context);
                                    }
                                  : null,
                              child: (_todocontroller.text.length > 0)
                                  ? Text(
                                      "ADD",
                                      style: GoogleFonts.firaSansCondensed(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      '--',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
