import 'package:task_mate/model/todo.dart';

class Tasks {
  final String id;
  final String title;
  // final Icon? icon;
  final String? color;
  // final List<dynamic> todos;
  final List<Todo> todos;
  final DateTime createdAt;
  final String uid;
  final bool isPending;
  final bool isCompleted;
  final int karma;

  const Tasks({
    required this.id,
    required this.title,
    // this.icon,
    this.color,
    this.todos = const [],
    required this.createdAt,
    required this.uid,
    required this.isPending,
    required this.isCompleted,
    this.karma = 0,
  });

  Tasks copyWith({
    String? id,
    String? title,
    // Icon? icon,
    String? color,
    // List<dynamic>? todos,
    List<Todo>? todos,
    bool? isPending,
    bool? isCompleted,
    int? karma,
  }) {
    return Tasks(
      id: id ?? this.id,
      title: title ?? this.title,
      // icon: icon ?? this.icon,
      color: color ?? this.color,
      todos: todos ?? this.todos,
      createdAt: createdAt,
      uid: uid,
      isPending: isPending ?? this.isPending,
      isCompleted: isCompleted ?? this.isCompleted,
      karma: karma ?? this.karma,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      // 'icon': icon,
      'color': color,
      'todos': todos,
      'createdAt': createdAt,
      'uid': uid,
      'isPending': isPending,
      'isCompleted': isCompleted,
      'karma': karma,
    };
  }

  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
      id: map['id'],
      title: map['title'],
      // icon: map['icon'],
      color: map['color'],
      // todos: map['todos'],
      todos: List<Todo>.from(map['todos']?.map((x) => Todo.fromMap(x))),
      createdAt: map['createdAt'].toDate(),
      uid: map['uid'],
      isPending: map['isPending'],
      isCompleted: map['isCompleted'],
      karma: map['karma'],
    );
  }

  @override
  String toString() {
    return 'Tasks(id: $id, title: $title, color: $color, todos: $todos, createdAt: $createdAt, uid: $uid, isPending: $isPending, isCompleted: $isCompleted, karma: $karma)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tasks &&
        other.id == id &&
        other.title == title &&
        // other.icon == icon &&
        other.color == color &&
        other.todos == todos &&
        other.createdAt == createdAt &&
        other.uid == uid &&
        other.isPending == isPending &&
        other.isCompleted == isCompleted &&
        other.karma == karma;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        // icon.hashCode ^
        color.hashCode ^
        todos.hashCode ^
        createdAt.hashCode ^
        uid.hashCode ^
        isPending.hashCode ^
        isCompleted.hashCode ^
        karma.hashCode;
  }
}
