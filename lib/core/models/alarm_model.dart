class Alarm {
  final int id;
  final String createdAt;
  final int? userId;
  final String alarmType;
  final String content;
  final bool isChecked;
  final Map<String, dynamic>? data;

  Alarm({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.alarmType,
    required this.content,
    required this.isChecked,
    this.data,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      userId: json['user_id'] as int,
      alarmType: json['type'] as String,
      content: json['content'] as String,
      isChecked: json['is_checked'] as bool,
      data: json['data'],
    );
  }

  int? get friendId => data?['friend_id'] as int?;
  int? get postId => data?['post_id'] as int?;
}
