class Attachment {
  final String imagePath;
  final String imageName;

  Attachment({
    required this.imagePath,
    required this.imageName,
  });

  Attachment copyWith({
    String? imagePath,
    String? imageName,
  }) {
    return Attachment(
      imagePath: imagePath ?? this.imagePath,
      imageName: imageName ?? this.imageName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'imageName': imageName,
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      imagePath: map['imagePath'],
      imageName: map['imageName'],
    );
  }

  String toJson() => '''
  {
    "imagePath": "$imagePath",
    "imageName": "$imageName"
  }
  ''';

  @override
  String toString() =>
      'Attachment(imagePath: $imagePath, imageName: $imageName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attachment &&
        other.imagePath == imagePath &&
        other.imageName == imageName;
  }

  @override
  int get hashCode => imagePath.hashCode ^ imageName.hashCode;
}
