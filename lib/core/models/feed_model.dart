class Feed {
  final int topicId;
  final String topic;
  final int postId;
  final int userId;
  final String imageUrl;
  final String createdAt;
  final int likes;
  final int comments;

  Feed({
    required this.topicId,
    required this.topic,
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      topicId: json['topic_id'] as int,
      topic: json['topic'] as String,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      imageUrl: json['imageUrl'] as String,
      createdAt: json['created_at'] as String,
      comments: json['comment_count'] as int? ?? 0,
      likes: json['like_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic_id': topicId,
      'topic': topic,
      'post_id': postId,
      'user_id': userId,
      'imageUrl': imageUrl,
      'created_at': createdAt,
      'comment_count': comments,
      'like_count': likes,
    };
  }
}
