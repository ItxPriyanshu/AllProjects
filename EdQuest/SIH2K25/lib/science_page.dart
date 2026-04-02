import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:sih_2k25/science_chapters/chapter1.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SciencePage(),
    );
  }
}

class SciencePage extends StatelessWidget {
  final List<Map<String, dynamic>> chapters = const [
    {"number": "1", "name": "Motion", "status": "completed"},
    {"number": "2", "name": "Chapter 2", "status": "completed"},
    {"number": "3", "name": "Chapter 3", "status": "current"},
    {"number": "4", "name": "Chapter 4", "status": "locked"},
    {"number": "5", "name": "Chapter 5", "status": "locked"},
  ];

  const SciencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const double centerColumnW = 80;
    final double sideSlotW =
        ((screenW - centerColumnW) / 2).clamp(80.0, screenW);

    const double circleDiameter = 68;
    const double connectorHeight = 100;
    const double connectorWidth = 24;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [  Color.fromARGB(255, 91, 181, 255), Color.fromARGB(255, 255, 255, 255)],
            ),
          ),
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 30),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final isLeft = index % 2 == 0;
              final showConnectorAbove = index != chapters.length - 1;

              final itemHeight =
                  circleDiameter + (showConnectorAbove ? connectorHeight : 0);

              return SizedBox(
                height: itemHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LEFT slot
                    SizedBox(
                      width: sideSlotW,
                      child: isLeft
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: _chapterBox(
                                context,
                                chapter["name"] ?? '',
                                width: sideSlotW * 0.95,
                                status: chapter["status"],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // CENTER column: connector above (if any), then the circle
                    SizedBox(
                      width: centerColumnW,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showConnectorAbove)
                            Container(
                              width: connectorWidth,
                              height: connectorHeight,
                              decoration: BoxDecoration(
                                color: Colors.grey
                                // borderRadius: BorderRadius.circular(connectorWidth / 2),
                              ),
                            ),
                          SizedBox(
                            width: circleDiameter,
                            height: circleDiameter,
                            child: _chapterCircle(chapter),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT slot
                    SizedBox(
                      width: sideSlotW,
                      child: !isLeft
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: _chapterBox(
                                context,
                                chapter["name"] ?? '',
                                width: sideSlotW * 0.95,
                                status: chapter["status"],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _chapterCircle(Map<String, dynamic> chapter) {
    final status = (chapter["status"] ?? "locked") as String;
    Color circleColor;
    Widget inner;

    switch (status) {
      case "completed":
        circleColor = Colors.green;
        inner = const Icon(Icons.check, color: Colors.white, size: 28);
        break;
      case "current":
        circleColor =  const Color.fromARGB(255, 239, 219, 38);
        inner = Text(
          chapter["number"] ?? '',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        );
        break;
      default:
        circleColor = const Color.fromARGB(255, 91, 181, 255);
        inner = Text(
          chapter["number"] ?? '',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        );
    }

    return Container(
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        boxShadow: status == "current"
            ? [
                BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.5),
                    blurRadius: 14,
                    spreadRadius: 2),
              ]
            : [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: const Offset(2, 4)),
              ],
      ),
      child: Center(child: inner),
    );
  }

  Widget _chapterBox(BuildContext context, String text,
      {required double width, String? status}) {
    return GestureDetector(
      onTap: () {
        if (status != "locked") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterDetailPage(chapterName: text),
            ),
          );
        }
      },
      child: SizedBox(
        width: width,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white70),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(2, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book,
                color: status == "completed" ? Colors.green : Colors.orange[900],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AutoSizeText(
                  text,
                  maxLines: 1,
                  minFontSize: 8,
                  stepGranularity: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


