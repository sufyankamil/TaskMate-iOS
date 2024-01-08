import 'session_todo_model.dart';

class Session {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final String endedAt;
  final List<SessionTodo> tasks;
  final List<String> usersJoined;

  const Session({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    this.endedAt = '',
    this.tasks = const [],
    this.usersJoined = const [],
  });

  Session copyWith({
    String? id,
    String? ownerId,
    String? endedAt,
    List<SessionTodo>? tasks,
    List<String>? usersJoined,
  }) {
    return Session(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt,
      endedAt: endedAt ?? this.endedAt,
      tasks: tasks ?? this.tasks,
      usersJoined: usersJoined ?? this.usersJoined,
    );
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      ownerId: map['ownerId'],
      createdAt: map['createdAt'].toDate(),
      endedAt: map['endedAt'],
      tasks: List<SessionTodo>.from(
        map['todos']?.map(
          (x) => SessionTodo.fromMap(x),
        ),
      ),
      usersJoined: List<String>.from(map['usersJoined']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'endedAt': endedAt,
      'todos': tasks.map((x) => x.toMap()).toList(),
      'usersJoined': usersJoined,
    };
  }

  @override
  String toString() {
    return 'Session(id: $id, ownerId: $ownerId, createdAt: $createdAt, endedAt: $endedAt, tasks: $tasks, usersJoined: $usersJoined)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.createdAt == createdAt &&
        other.endedAt == endedAt &&
        other.tasks == tasks &&
        other.usersJoined == usersJoined;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ownerId.hashCode ^
        createdAt.hashCode ^
        endedAt.hashCode ^
        tasks.hashCode ^
        usersJoined.hashCode;
  }
}
