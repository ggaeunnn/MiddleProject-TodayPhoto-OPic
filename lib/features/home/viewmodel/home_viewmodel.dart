import 'package:flutter/foundation.dart';
import 'package:opicproject/features/home/data/home_repository.dart';
import 'package:opicproject/features/post/data/post_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final PostRepository repository = PostRepository.shared;
  final HomeRepository topicRepository = HomeRepository.shared;

  List<Map<String, dynamic>> topics = [];
  Map<String, dynamic>? todayTopic;
  int currentTopicIndex = 0;

  List<Map<String, dynamic>> posts = [];

  // 게시글 올리기
  Future<void> loadPosts() async {
    posts = await repository.getAllPosts();
    notifyListeners();
  }

  Future<void> fetchPosts() async {
    posts = await repository.getAllPosts();
    notifyListeners();
  }

  Future<void> loadTopics() async {
    todayTopic = await topicRepository.fetchTodayTopic();
    notifyListeners();
  }

  void _setTodayTopic() {
    final now = DateTime.now();
    final dayNumber = now.difference(DateTime(2025)).inDays;

    currentTopicIndex = dayNumber % topics.length;
    todayTopic = topics[currentTopicIndex];

    notifyListeners();
  }

  Future<void> initHome() async {
    await loadPosts();
    await loadTopics();
  }
}
