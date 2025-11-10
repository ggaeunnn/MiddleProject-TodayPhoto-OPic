import 'dart:core';

class UserInfo {
  final int id;
  final String nickname;
  final String createdAt;
  final String email;
  final int platformId;
  final String? exitAt;
  final String token;
  final String? uuid;

  UserInfo({
    required this.id,
    required this.nickname,
    required this.createdAt,
    required this.email,
    required this.platformId,
    required this.token,
    required this.uuid,
    this.exitAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      nickname: json['nickname'] as String? ?? '',
      createdAt: json['created_at'] as String,
      email: json['email'] as String,
      platformId: json['platform_id'] as int,
      exitAt: json['exit_at'] as String? ?? '',
      token: json['token'] as String? ?? '',
      uuid: json['uuid'] as String,
    );
  }

  static List<UserInfo> getDummyUsers() {
    return [
      UserInfo(
        id: 1,
        nickname: "찍사",
        createdAt: DateTime.now().toString(),
        email: "random@mail.com",
        platformId: 1,
        exitAt: null,
        token: "token1",
        uuid: "uuid1",
      ),
      UserInfo(
        id: 2,
        nickname: "찰칵",
        createdAt: DateTime.now().toString(),
        email: "user@test.com",
        platformId: 2,
        exitAt: null,
        token: "token2",
        uuid: "uuid2",
      ),
    ];
  }
}
