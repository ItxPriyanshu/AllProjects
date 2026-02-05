
class TodoModel {
  final String title;
  final bool isDone;
  TodoModel({
    required this.title,
     this.isDone=false,
  });

  TodoModel copyWith({
    String? title,
    bool? isDone,
  }) {
    return TodoModel(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
