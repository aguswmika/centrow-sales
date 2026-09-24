class AddendumTemplate {
  final String id;
  final String title;

  const AddendumTemplate({required this.id, required this.title});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddendumTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  @override
  String toString() => 'AddendumTemplate(id: $id, title: $title)';
}
