import 'package:dropnote/models/note_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final noteProvider = StateNotifierProvider<NotesNotifier,List<Note> >((ref) {
  return NotesNotifier();
});

class NotesNotifier extends StateNotifier<List<Note>>{
  NotesNotifier():super([]);


  //operations//
  //add note
  void addNote(Note note){
    state = [...state,note];
  }

//remove note
  void deleteNote(String id){
    state = state.where((n)=>n.id!= id).toList();
  }

  //update note 
  void updateNote(Note updated){
    state = [
      for(final note in state)
      if(note.id==updated.id) updated else note
    ];
  }
}
