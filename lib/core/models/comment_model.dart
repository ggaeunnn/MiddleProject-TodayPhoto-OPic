class Comment {
  final int id;
  final String createdAt;
  final int postId;
  final int userId;
  final String text;
  final String? deletedAt;
  final bool isDeleted;

  Comment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.userId,
    required this.text,
    required this.isDeleted,
    this.deletedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      text: json['text'] as String,
      deletedAt: json['deleted_at'] as String?,
      isDeleted: json['is_deleted'] as bool,
    );
  }
}
