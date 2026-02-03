import 'package:dropnote/models/note_model.dart';

List<Note> dummyNotes = [
  Note(
    id: '1',
    title: 'Private Note',
    description: 'This is my private note',
    isPublic: false,
    createdAt: DateTime.now(),
  ),
  Note(
    id: '2',
    title: 'Public Note',
    description: 'Anyone can see this note',
    isPublic: true,
    createdAt: DateTime.now(),
  ),
];