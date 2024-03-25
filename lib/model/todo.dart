import 'attachments.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  bool isPending;
  bool inProgress;
  bool isDone;
  final String? assignedBy;
  final String? assignedTo;
  final List<Attachment>? attachments;
  final String? comments;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isPending,
    required this.inProgress,
    required this.isDone,
    
    this.assignedBy,
    this.assignedTo,
    this.attachments,
    this.comments,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isPending,
    bool? inProgress,
    bool? isDone,
    String? assignedBy,
    String? assignedTo,
    List<Attachment>? attachments,
    String? comments,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isPending: isPending ?? this.isPending,
      inProgress: inProgress ?? this.inProgress,
      isDone: isDone ?? this.isDone,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
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
      'assignedBy': assignedBy,
      'assignedTo': assignedTo,
      'attachments':
          attachments?.map((attachment) => attachment.toMap()).toList(),
      'comments': comments,
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
      assignedBy: map['assignedBy'],
      assignedTo: map['assignedTo'],
      attachments: List<Attachment>.from(
          map['attachments']?.map((x) => Attachment.fromMap(x))),
      comments: map['comments'],
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
