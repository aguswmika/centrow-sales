import 'package:flutter/foundation.dart';

@immutable
class Segment {
  final String id;
  final String name;
  final String createdAt;

  const Segment({required this.id, required this.name, this.createdAt = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Segment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Segment(id: $id, name: $name)';
}
