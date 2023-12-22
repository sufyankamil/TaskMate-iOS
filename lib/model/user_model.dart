class UserModel {
  final String name;
  final String email;
  final String photoUrl;
  final String banner;
  final String uid;
  final String lastSeen;
  final bool isAuthenticated; // is guest or not
  final int karma;

  UserModel({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.banner,
    required this.uid,
    required this.lastSeen,
    required this.isAuthenticated,
    required this.karma,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? banner,
    String? uid,
    String? lastSeen,
    bool? isAuthenticated,
    int? karma,
    List<String>? awards,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      lastSeen: lastSeen ?? this.lastSeen,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      karma: karma ?? this.karma,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      banner: map['banner'],
      uid: map['uid'],
      lastSeen: map['lastSeen'],
      isAuthenticated: map['isAuthenticated'],
      karma: map['karma'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'banner': banner,
      'uid': uid,
      'lastSeen': lastSeen,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
    };
  }

  // to read user modal class from firebase
  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, photoUrl: $photoUrl, banner: $banner, uid: $uid, lastSeen: $lastSeen, isAuthenticated: $isAuthenticated, karma: $karma)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.name == name &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.banner == banner &&
        other.uid == uid &&
        other.lastSeen == lastSeen &&
        other.isAuthenticated == isAuthenticated &&
        other.karma == karma;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        photoUrl.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        lastSeen.hashCode ^
        isAuthenticated.hashCode ^
        karma.hashCode;
  }
}
