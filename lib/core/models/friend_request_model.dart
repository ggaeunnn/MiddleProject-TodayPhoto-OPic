class FriendRequest {
  final int id;
  final String createdAt;
  final int requestId;
  final int targetId;
  final String? answeredAt;
  FriendRequest({
    required this.id,
    required this.createdAt,
    required this.requestId,
    required this.targetId,
    this.answeredAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      requestId: json['request_id'] as int,
      targetId: json['target_id'] as int,
      answeredAt: json['answered_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'request_id': requestId,
      'target_id': targetId,
      'answered_at': answeredAt,
    };
  }
}
