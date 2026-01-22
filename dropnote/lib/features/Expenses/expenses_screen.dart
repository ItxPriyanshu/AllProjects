import 'package:dropnote/features/Expenses/components/customtextfield.dart';
import 'package:dropnote/models/expense_item.dart';
import 'package:dropnote/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController spentoncontroller = TextEditingController();
  final TextEditingController amountcontroller = TextEditingController();

  late AnimationController _controller;
  int playcount = 0;

  @override
  void initState() {
    super.initState();

    //animation controller which control the lottie
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        playcount++;
        if (playcount < 1) {
          _controller.forward(from: 0);
        } else {
          _controller.stop();
        }
      }
    });
  }

  //disposing the animation controller to avoid memory leak
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        body: Stack(
          children: [
            //money rain lottie
            Lottie.asset(
              'assets/lotties/CashRain.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                _controller.forward();
              },
            ),
            // app bar //
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  bottom: 10,
                  right: 10,
                  top: 15,
                ),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Lottie.asset(
                        'assets/lotties/MoneyInvestment.json',
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Expenses',
                        style: GoogleFonts.firaSans(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Total',
                        style: GoogleFonts.firaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 50,),
                    //list of expenses
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return ListTile(
                          title: Text(expense.name,style: GoogleFonts.firaSans(fontWeight: FontWeight.bold),),

                          subtitle: Text(DateFormat('dd mm yyyy,   HH:mm').format(expense.dateTime)),
                          trailing: Text("₹${expense.amount}",style: GoogleFonts.firaSans(fontWeight: FontWeight.bold,fontSize: 17),),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        //floating action button//
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.white.withAlpha(100),
          backgroundColor: const Color.fromARGB(255, 56, 131, 59),
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
                        color: Color.fromARGB(255, 12, 154, 7),
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
                              "Add Expense",
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
                              title: 'Spent on',
                              controller: spentoncontroller,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                              right: 25,
                              bottom: 8,
                              top: 8,
                            ),
                            child: expenseTextField(
                              keyboardType: TextInputType.number,
                              title: 'Amount',
                              controller: amountcontroller,
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
                              onPressed: () {
                                final newExpense = ExpenseItem(
                                  name: spentoncontroller.text,
                                  amount: amountcontroller.text,
                                  dateTime: DateTime.now(),
                                );

                                ref.read(expenseProvider.notifier).addNewExpense(newExpense);
                                spentoncontroller.clear();
                                amountcontroller.clear();
                                Navigator.pop(context);
                              },
                              child: Text(
                                "ADD",
                                style: GoogleFonts.firaSansCondensed(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
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
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
