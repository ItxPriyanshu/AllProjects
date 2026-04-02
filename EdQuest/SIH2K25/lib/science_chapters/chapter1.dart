import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sih_2k25/downloaded_pdfs.dart';
import 'package:sih_2k25/simulation.dart';
import 'package:sih_2k25/unity_splash_screen.dart';
import 'package:lottie/lottie.dart';


class ChapterDetailPage extends StatelessWidget {
  final String chapterName;

  const ChapterDetailPage({super.key, required this.chapterName});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapterName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () {
              if (!downloadedPdfs.contains(chapterName)) {
                downloadedPdfs.add(chapterName);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Downloading $chapterName...")),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 91, 181, 255), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text with inline image
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'topic1'.tr(),
                              style: const TextStyle(fontSize: 30),
                            ),
                            const TextSpan(text: '\n'),
                            TextSpan(text: 'content1'.tr()),
                            const TextSpan(text: '\n'),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                ),
                                child:
                                    Image.asset('assets/images/science_motion.png'),
                              ),
                            ),
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: 'topic2'.tr(),
                              style: const TextStyle(fontSize: 30),
                            ),
                            const TextSpan(text: '\n'),
                            TextSpan(text: 'content2'.tr()),
                          ],
                        ),
                      ),
                      SizedBox(height: 50,),
                      Text('Quiz Quest',style: TextStyle(fontFamily: 'Barlow',fontWeight: FontWeight.w700,fontSize: 20),),
                      const SizedBox(height: 20),

                      // Full width card (tappable) — opens Unity game page
                      Card(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            // Navigate to UnityGamePage when card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UnitySplashPage(),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: screenWidth,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 180,
                                  child: Image.asset('assets/images/quizquest.png'),
                                  
                                ),
                               
                                
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50,),
                      Text('3D Animations',style: TextStyle(fontFamily: 'Barlow',fontWeight: FontWeight.w700,fontSize: 20),),
                      SizedBox(height: 20,),
                       Container(
                        width: double.infinity,
                        color: Colors.black,
                         child: IconButton(
                          
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TechStackCloud(),
                              ),
                            );
                          },
                          icon: Lottie.asset('assets/lottie/rotation.json'),
                                               ),
                       ),
                    ],
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
