import 'dart:core';

class User {
  final int id;
  final String nickname;
  final String createdAt;
  final String email;
  final int platformId;
  final String? exitAt;
  final String token;

  User({
    required this.id,
    required this.nickname,
    required this.createdAt,
    required this.email,
    required this.platformId,
    required this.token,
    this.exitAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      createdAt: json['created_at'] as String,
      email: json['email'] as String,
      platformId: json['platform_id'] as int,
      exitAt: null,
      token: json['token'] as String,
    );
  }

  static List<User> getDummyUsers() {
    return [
      User(
        id: 0,
        nickname: "찍사",
        createdAt: DateTime.now().toString(),
        email: "random@mail.com",
        platformId: 1,
        exitAt: null,
        token: "token1",
      ),
      User(
        id: 1,
        nickname: "찰칵",
        createdAt: DateTime.now().toString(),
        email: "user@test.com",
        platformId: 2,
        exitAt: null,
        token: "token2",
      ),
    ];
  }
}
