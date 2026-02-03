class Note {
  final String id;
  final String title;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.isPublic,
    required this.createdAt,
  });
}
