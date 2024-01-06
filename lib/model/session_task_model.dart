class SessionTasks{
  final String id;
  final String ownerId; // user id(uid)
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;

  const SessionTasks({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
  });

  SessionTasks copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? date,
    String? time,
    String? status,
  }) {
    return SessionTasks(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'status': status,
    };
  }

  factory SessionTasks.fromMap(Map<String, dynamic> map) {
    return SessionTasks(
      id: map['id'],
      ownerId: map['ownerId'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
    );
  }

    @override
  String toString() {
    return 'SessionTasks(id: $id, ownerId: $ownerId, title: $title, description: $description, date: $date, time: $time, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SessionTasks &&
      other.id == id &&
      other.ownerId == ownerId &&
      other.title == title &&
      other.description == description &&
      other.date == date &&
      other.time == time &&
      other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      ownerId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      date.hashCode ^
      time.hashCode ^
      status.hashCode;
  }
}