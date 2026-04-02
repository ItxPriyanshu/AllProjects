import 'package:flutter/material.dart';
import 'downloaded_pdfs.dart'; // Import global list

class ScienceLibrary extends StatelessWidget {
  const ScienceLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library',style: TextStyle(fontFamily: 'Barlow',fontWeight: FontWeight.w700),),centerTitle: true,),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ Color.fromARGB(255, 91, 181, 255), Colors.white],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
             
              const SizedBox(height: 20),

              // Show empty message OR list
              Expanded(
                child: downloadedPdfs.isEmpty
                    ? const Center(
                        child: Text(
                          "Library is empty",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: downloadedPdfs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: const BorderSide(
                                  color: Colors.black54,
                                  width: 1,
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Opening ${downloadedPdfs[index]}...",
                                    ),
                                  ),
                                );
                                // TODO: Add actual PDF opening logic here
                              },
                              child: Text(
                                downloadedPdfs[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
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
