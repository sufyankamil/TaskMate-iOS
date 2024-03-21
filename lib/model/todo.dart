class Todo {
  final String id;
  final String title;
  final String description;
  bool isPending;
  bool inProgress;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isPending,
    required this.inProgress,
    required this.isDone,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isPending,
    bool? inProgress,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isPending: isPending ?? this.isPending,
      inProgress: inProgress ?? this.inProgress,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isPending': isPending,
      'inProgress': inProgress,
      'isDone': isDone,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isPending: map['isPending'],
      inProgress: map['inProgress'],
      isDone: map['isDone'],
    );
  }

  void togglePending() {
    isPending = !isPending;
  }

  void toggleInProgress() {
    inProgress = !inProgress;
  }

  void toggleDone() {
    isDone = !isDone;
  }
}
