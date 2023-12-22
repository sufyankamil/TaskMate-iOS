
import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String title;
  final int icon;
  final String color;
  final List<dynamic>? todos;

  const Task({
    required this.title,
    required this.icon,
    required this.color,
    this.todos,
  });

  Task copyWith({
    String? title,
    int? icon,
    String? color,
    List<dynamic>? todos,
  }) {
    return Task(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      todos: todos ?? this.todos,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      icon: json['icon'],
      color: json['color'],
      todos: json['todos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'color': color,
      'todos': todos,
    };
  }

  @override
  String toString() {
    return 'Task(title: $title, icon: $icon, color: $color, todos: $todos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.title == title &&
        other.icon == icon &&
        other.color == color &&
        other.todos == todos;
  }

  @override
  int get hashCode {
    return title.hashCode ^ icon.hashCode ^ color.hashCode ^ todos.hashCode;
  }

  @override
  List<Object?> get props => [title, icon, color, todos];
}
