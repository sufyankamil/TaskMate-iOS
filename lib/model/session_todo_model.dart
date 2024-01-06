class SessionTodo {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;
  final String uid;
  final bool isPending;
  final bool isCompleted;
  final int karma;

  const SessionTodo({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.uid,
    required this.isPending,
    required this.isCompleted,
    this.karma = 0,
  });

  SessionTodo copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? status,
    String? uid,
    bool? isPending,
    bool? isCompleted,
    int? karma,
  }) {
    return SessionTodo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      uid: uid ?? this.uid,
      isPending: isPending ?? this.isPending,
      isCompleted: isCompleted ?? this.isCompleted,
      karma: karma ?? this.karma,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'status': status,
      'uid': uid,
      'isPending': isPending,
      'isCompleted': isCompleted,
      'karma': karma,
    };
  }

  factory SessionTodo.fromMap(Map<String, dynamic> map) {
    return SessionTodo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
      uid: map['uid'],
      isPending: map['isPending'],
      isCompleted: map['isCompleted'],
      karma: map['karma'],
    );
  }

  @override
  String toString() {
    return 'SessionTodo(id: $id, title: $title, description: $description, date: $date, time: $time, status: $status, uid: $uid, isPending: $isPending, isCompleted: $isCompleted, karma: $karma)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionTodo &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.date == date &&
        other.time == time &&
        other.status == status &&
        other.uid == uid &&
        other.isPending == isPending &&
        other.isCompleted == isCompleted &&
        other.karma == karma;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        date.hashCode ^
        time.hashCode ^
        status.hashCode ^
        uid.hashCode ^
        isPending.hashCode ^
        isCompleted.hashCode ^
        karma.hashCode;
  }
}
