class Friend {
  final int id;
  final String createdAt;
  final int user1Id;
  final int user2Id;

  Friend({
    required this.id,
    required this.createdAt,
    required this.user1Id,
    required this.user2Id,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      user1Id: json['user1_id'] as int,
      user2Id: json['user2_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'user1_id': user1Id,
      'user2_id': user2Id,
    };
  }
}
