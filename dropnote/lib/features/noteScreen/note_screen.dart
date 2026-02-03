import 'package:dropnote/data/note_data.dart';
import 'package:dropnote/features/NoteScreen/create_note.dart';
import 'package:dropnote/features/landingscreen/components/carousel_slider.dart';
import 'package:dropnote/features/NoteScreen/components/note_card.dart';
import 'package:dropnote/features/NoteScreen/components/random_color.dart';
import 'package:dropnote/models/note_model.dart';
import 'package:dropnote/providers/notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Note> notes = [...dummyNotes];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watcher/observer/listener//
    final notes = ref.watch(noteProvider);

    final myNotes = notes.where((n) => !n.isPublic).toList();
    final PublicNotes = notes.where((n) => n.isPublic).toList();

    DateTime current_date_time = DateTime.now();
    String fromatteddate = DateFormat('dd-MM-yyyy').format(current_date_time);
    String formattedtime = DateFormat('HH:mm a').format(current_date_time);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      appBar: AppBar(
        title: Text('Notes', style: GoogleFonts.firaSansCondensed()),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Notes'),
            Tab(text: 'Public Notes'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNote()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildList(myNotes), buildList(PublicNotes)],
      ),
    );
  }
}

Widget buildList(List<Note> list) {
  if (list.isEmpty) {
    return const Center(
      child: Text('No Notes', style: TextStyle(color: Colors.white70)),
    );
  }
  return ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, index) {
      final note = list[index];
      return NoteCard(
        headerText: note.title,
        descriptionText: note.description,
        color: getRandomColor().withAlpha(60),
      );
    },
  );
}
