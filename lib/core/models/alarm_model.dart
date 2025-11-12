class Alarm {
  final int id;
  final String createdAt;
  final int? userId;
  final String alarmType;
  final String content;
  final bool isChecked;
  final String? targetUrl;

  Alarm({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.alarmType,
    required this.content,
    required this.isChecked,
    this.targetUrl,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      userId: json['user_id'] as int,
      alarmType: json['type'] as String,
      content: json['content'] as String,
      isChecked: json['is_checked'] as bool,
      targetUrl: json['target_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'user_id': userId,
      'type': alarmType,
      'content': content,
      'is_checked': isChecked,
      'target_url': targetUrl,
    };
  }
}
