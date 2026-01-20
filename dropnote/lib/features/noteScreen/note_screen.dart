import 'package:dropnote/features/landingscreen/components/carousel_slider.dart';
import 'package:dropnote/features/noteScreen/components/note_card.dart';
import 'package:dropnote/features/noteScreen/components/random_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  
  @override
  Widget build(BuildContext context) {
    DateTime current_date_time = DateTime.now();
  String fromatteddate= DateFormat('dd-MM-yyyy').format(current_date_time);
  String formattedtime = DateFormat('HH:mm a').format(current_date_time);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),

      body: Column(
        children: [
          
          //**top part**//

          // MyCarouselSlider(),
          //  Text('Features',style:GoogleFonts.firaSansCondensed(fontSize: 15,fontWeight: FontWeight.bold),),
          // SizedBox(height: 10),

          //line below carousel slider
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Container(color: Colors.grey.withAlpha(100), height: 1),
          ),

          //**mid part**//
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: NoteCard(
                        headerText: 'Heading',
                        descriptionText:
                            'note ka description likhenge yaha jo kuch bhi ho sakta hai and in future image upload ka bhi option denge to balle balle hbjhhjbjbjbkjbbjbhbbjkbjbbjkbjkbbjbbjbbbhhkbkbbbkhhhhjkbhkjhbjkbhbkbkjhbbbbbbhbbbjbhbjbjbbjbjhbjkbj',
                        color: getRandomColor().withAlpha(50),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      // child: MyCarouselSlider(),
                    ),
                     Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(fromatteddate),
                          Text(formattedtime),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
