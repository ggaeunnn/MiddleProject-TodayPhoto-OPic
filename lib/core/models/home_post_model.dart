import 'dart:math';

class HomePost {
  final int topicId;
  final String topic;
  final int postId;
  final int userId;
  final String imageUrl;
  final String createdAt;
  final int likes;
  final int comments;

  HomePost({
    required this.topicId,
    required this.topic,
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  factory HomePost.fromJson(Map<String, dynamic> json) {
    return HomePost(
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
  static final List<HomePost> fixedDummyPosts = generateDummyData(4);
  //더미데이터 리스트 생성 데이터 베이스 붙히면 나중에 지워야함
  static List<HomePost> generateDummyData(int count) {
    final Random random = Random();
    final List<HomePost> dummyList = [];

    // 더미 데이터에 사용할 리스트
    final List<String> dummyTopics = [
      '겨울 풍경',
      '따뜻한 일상',
      '여행 기록',
      '나의 하루',
      '감성 사진',
    ];
    final List<String> dummyImagePaths = [
      'https://images.unsplash.com/photo-1455156218388-5e61b526818b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFQSVCMiVBOCVFQyU5QSVCOHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
      'https://images.unsplash.com/photo-1527784281695-866fa715d9d8?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8JUVDJTlEJUJDJUVDJTgzJTgxfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500',
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8JUVDJTk3JUFDJUVEJTk2JTg5fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500',
      'https://images.unsplash.com/photo-1655712937984-eb3ba4d17479?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8JUVCJTgyJTk4JUVDJTlEJTk4JTIwJUVEJTk1JTk4JUVCJUEzJUE4fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500',
      'https://images.unsplash.com/photo-1713252977795-535eeec04d52?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fCVFQSVCMCU5MCVFQyU4NCVCMSVFQyU4MiVBQyVFQyVBNyU4NHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
    ];

    for (int i = 0; i < count; i++) {
      dummyList.add(
        HomePost(
          topicId: random.nextInt(5) + 1,
          topic: dummyTopics[random.nextInt(dummyTopics.length)],
          postId: 100 + i,
          userId: random.nextInt(10) + 1,
          imageUrl: dummyImagePaths[random.nextInt(dummyImagePaths.length)],
          createdAt: DateTime.now().toString(),
          likes: random.nextInt(1001),
          comments: random.nextInt(51),
        ),
      );
    }

    return dummyList;
  }
}
