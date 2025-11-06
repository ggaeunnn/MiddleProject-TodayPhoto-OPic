class Topic {
  final int id;
  final String content;
  final String uploadedAt;

  Topic({required this.id, required this.content, required this.uploadedAt});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      content: json['content'] as String,
      uploadedAt: json['uploaded_at'] as String,
    );
  }
}
