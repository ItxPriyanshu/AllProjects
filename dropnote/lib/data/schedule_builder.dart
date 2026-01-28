import 'package:dropnote/models/schedule_cell.dart';
import 'package:flutter_riverpod/legacy.dart';

class ScheduleNotifier extends StateNotifier<List<ScheduleCell?>>{
  ScheduleNotifier():super(List.filled(70, null));

  void addOrUpdate(int index,ScheduleCell cell){
    final copy = [...state];
    copy[index] = cell;
    state = copy;
  }

  void delete(int index){
    final copy = [...state];
    copy[index] = null;
    state = copy;
  }
}