import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sih_2k25/science_library.dart';

class Library2 extends StatelessWidget {
  final List<Map<String, String>> chapters = [
    {"name": "Science", "lottie": "assets/lottie/science_lottie.json"},
    {"name": "Maths", "lottie": "assets/lottie/math_chapterslottie.json"},
    {"name": "Computer", "lottie": "assets/lottie/computer_lottie.json"},
  ];

  Library2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 26, 117, 245),
        title: Text(
          "Chapters",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            // stops: const[0.7,0.3],
            colors: [
              // Color.fromARGB(255, 70, 155, 240),
              Colors.white,
             Colors.white
             ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // two columns
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9, // adjust size of card
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return GestureDetector(
                      onTap: () {
                        //we'll use if else logic for navigating in future for different chapters
                        switch(index){
                          case 0:{
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScienceLibrary(),
                          ),
                        );
                          }
                          case 1:{
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScienceLibrary(),
                          ),
                        );
                          }
                          case 2:{Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScienceLibrary(),
                          ),
                        );}
                        }
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 219, 239, 255),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Lottie.asset(
                                chapter["lottie"]!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chapter["name"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
