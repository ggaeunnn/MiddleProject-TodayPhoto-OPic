class BlockUser {
  final int id;
  final int userId;
  final int blockedUserId;
  final String blockedAt;

  BlockUser({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.blockedAt,
  });

  factory BlockUser.fromJson(Map<String, dynamic> json) {
    return BlockUser(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      blockedUserId: json['blocked_user'] as int,
      blockedAt: json['blocked_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'blocked_user': blockedUserId,
      'blocked_at': blockedAt,
    };
  }
}
