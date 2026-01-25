// ignore_for_file: public_member_api_docs, sort_constructors_first
class AlarmModel {
 final int id;
 final DateTime dateTime;
 final bool repeat;
 final String difficulty;
 final bool enabled;
  AlarmModel({
    required this.id,
    required this.dateTime,
    required this.repeat,
    required this.difficulty,
    required this.enabled,
  });


  AlarmModel copyWith({
    int? id,
    DateTime? dateTime,
    bool? repeat,
    String? difficulty,
    bool? enabled,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      repeat: repeat ?? this.repeat,
      difficulty: difficulty ?? this.difficulty,
      enabled: enabled ?? this.enabled,
    );
  }
}
