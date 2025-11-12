class Post {
  final int id;
  final String createdAt;
  final int userId;
  final String imageUrl;
  final int topicId;
  final String? deletedAt;
  final bool isDeleted;

  Post({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.imageUrl,
    required this.topicId,
    this.deletedAt,
    required this.isDeleted,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      userId: json['user_id'] as int,
      imageUrl: json['image_url'] as String,
      topicId: json['topic_id'] as int,
      deletedAt: json['deleted_at'] as String?,
      isDeleted: json['is_deleted'] as bool,
    );
  }
}
