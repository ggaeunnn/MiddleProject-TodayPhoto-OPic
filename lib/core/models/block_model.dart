class Block {
  final int id;
  final int userId;
  final int blockedUserId;
  final String blockedAt;

  Block({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.blockedAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      blockedUserId: json['blocked_user_id'] as int,
      blockedAt: json['blocked_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'blocked_user_id': blockedUserId,
      'blocked_at': blockedAt,
    };
  }
}
