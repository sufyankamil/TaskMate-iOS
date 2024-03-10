import 'package:cloud_firestore/cloud_firestore.dart';

import 'session_todo_model.dart';

class Session {
  final String id;
  final String ownerId;
  final Timestamp sessionCreatedAt;
  final String? endedAt;
  final List<SessionTodo> tasks;
  final List<String> usersJoined;
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;
  final bool isPremium;
  bool isCollaborative;

  Session({
    required this.id,
    required this.ownerId,
    required this.sessionCreatedAt,
    this.endedAt,
    this.tasks = const [],
    this.usersJoined = const [],
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    this.isPremium = false,
    this.isCollaborative = false,
  });

  Session copyWith({
    String? id,
    String? ownerId,
    Timestamp? sessionCreatedAt,
    String? endedAt,
    List<SessionTodo>? tasks,
    List<String>? usersJoined,
    String? title,
    String? description,
    String? date,
    String? time,
    String? status,
    bool? isPremium,
    bool? isCollaborative,
  }) {
    return Session(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      sessionCreatedAt: sessionCreatedAt ?? this.sessionCreatedAt,
      endedAt: endedAt ?? this.endedAt,
      tasks: tasks ?? this.tasks,
      usersJoined: usersJoined ?? this.usersJoined,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      isCollaborative: isCollaborative ?? this.isCollaborative,
    );
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    print('Actual type of "sessionCreatedAt": ${map['sessionCreatedAt'].runtimeType}');
    return Session(
      id: map['id'],
      ownerId: map['ownerId'],
      sessionCreatedAt: map['sessionCreatedAt'] as Timestamp,
      endedAt: map['endedAt'],
      tasks: List<SessionTodo>.from(
        map['todos']?.map(
          (x) => SessionTodo.fromMap(x),
        ),
      ),
      usersJoined: List<String>.from(map['usersJoined']),
      title: map['title'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
      isPremium: map['isPremium'],
      isCollaborative: map['isCollaborative'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'sessionCreatedAt': sessionCreatedAt,
      'endedAt': endedAt,
      'todos': tasks.map((x) => x.toMap()).toList(),
      'usersJoined': usersJoined,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'status': status,
      'isPremium': isPremium,
      'isCollaborative': isCollaborative,
    };
  }

  @override
  String toString() {
    return 'Session(id: $id, ownerId: $ownerId, sessionCreatedAt: $sessionCreatedAt, endedAt: $endedAt, tasks: $tasks, usersJoined: $usersJoined, title: $title, description: $description, date: $date, time: $time, status: $status, isPremium: $isPremium, isCollaborative: $isCollaborative)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Session &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.sessionCreatedAt == sessionCreatedAt &&
        other.endedAt == endedAt &&
        other.tasks == tasks &&
        other.usersJoined == usersJoined &&
        other.title == title &&
        other.description == description &&
        other.date == date &&
        other.time == time &&
        other.status == status &&
        other.isPremium == isPremium &&
        other.isCollaborative == isCollaborative;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ownerId.hashCode ^
        sessionCreatedAt.hashCode ^
        endedAt.hashCode ^
        tasks.hashCode ^
        usersJoined.hashCode ^
        title.hashCode ^
        description.hashCode ^
        date.hashCode ^
        time.hashCode ^
        status.hashCode ^
        isPremium.hashCode ^
        isCollaborative.hashCode;
  }
}
