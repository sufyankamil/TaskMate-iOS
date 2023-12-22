class Todo {
  final String title;
  bool isDone;

  Todo({
    required this.title,
    required this.isDone,
  });

  Todo copyWith({
    String? title,
    bool? isDone,
  }) {
    return Todo(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      title: map['title'],
      isDone: map['isDone'],
    );
  }

   void toggleDone() {
    isDone = !isDone;
  }
}
