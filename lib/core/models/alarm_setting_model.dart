class AlarmSetting {
  final int id;
  final int userId;
  final String createdAt;
  final bool entireAlarm;
  final bool newTopic;
  final bool likePost;
  final bool newComment;
  final bool newRequest;
  final bool newFriend;
  final String? editedAt;

  AlarmSetting({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.entireAlarm,
    required this.newTopic,
    required this.likePost,
    required this.newComment,
    required this.newRequest,
    required this.newFriend,
    this.editedAt,
  });

  factory AlarmSetting.fromJson(Map<String, dynamic> json) {
    return AlarmSetting(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      createdAt: json['created_at'] as String,
      entireAlarm: json['entire_alarm'] as bool,
      newTopic: json['new_topic'] as bool,
      likePost: json['like_post'] as bool,
      newComment: json['new_comment'] as bool,
      newRequest: json['new_request'] as bool,
      newFriend: json['new_friend'] as bool,
      editedAt: json['edited_at'] as String?,
    );
  }
}
