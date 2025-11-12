class Alarm {
  final int id;
  final String createdAt;
  final int? userId;
  final AlarmType type;
  final String content;
  final bool isChecked;

  Alarm({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.type,
    required this.content,
    required this.isChecked,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      userId: json['user_id'] as int,
      type: json['type'] as AlarmType,
      content: json['content'] as String,
      isChecked: json['is_checked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'user_id': userId,
      'type': type,
      'content': content,
      'is_checked': isChecked,
    };
  }
}

enum AlarmType {
  NEW_TOPIC,
  NEW_FRIEND_REQUEST,
  NEW_FRIEND,
  NEW_LIKE,
  NEW_REPLY,
}
