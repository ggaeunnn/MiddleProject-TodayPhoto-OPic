import 'package:flutter/foundation.dart';
import 'package:opicproject/features/home/data/home_repository.dart';
import 'package:opicproject/features/post/data/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  final PostRepository repository = PostRepository.shared;
  final HomeRepository topicRepository = HomeRepository.shared;

  List<Map<String, dynamic>> topics = [];
  Map<String, dynamic>? todayTopic;
  int currentTopicIndex = 0;
  bool _isInitialized = false;
  List<Map<String, dynamic>> posts = [];

  // postId별로 likes/comments 저장 (중요!)
  int likes = 0;
  int comments = 0;

  bool get isToday {
    if (todayTopic == null || todayTopic!['uploaded_at'] == null) {
      return false;
    }

    try {
      final topicDate = DateTime.parse(todayTopic!['uploaded_at']);
      final now = DateTime.now();

      return topicDate.year == now.year &&
          topicDate.month == now.month &&
          topicDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchPosts() async {
    posts = await repository.getAllPosts();
    notifyListeners();
  }

  Future<void> fetchTopics() async {
    todayTopic = await topicRepository.fetchTodayTopic();

    if (todayTopic != null && todayTopic!['id'] != null) {
      await fetchPostsByTopicId(todayTopic!['id']);
    }
  }

  Future<void> initHome() async {
    if (_isInitialized) return;
    await fetchTopics();
    _isInitialized = true;
  }

  Future<void> fetchTopicByDate(DateTime selectedDate) async {
    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
      0,
    );

    final endOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    final result = await Supabase.instance.client
        .from('topic')
        .select('id, content, uploaded_at')
        .gte('uploaded_at', startOfDay.toIso8601String())
        .lte('uploaded_at', endOfDay.toIso8601String())
        .maybeSingle();

    if (result != null && result['content'] != null) {
      todayTopic = {
        'id': result['id'],
        'content': result['content'],
        'uploaded_at': result['uploaded_at'],
      };

      await fetchPostsByTopicId(result['id']);
    } else {
      todayTopic = {'content': "주제 없음"};
      posts = [];
      notifyListeners();
    }
  }

  Future<void> fetchPostsByTopicId(int topicId) async {
    posts = await repository.getPostsByTopicId(topicId);
    notifyListeners();
  }

  Future<void> getLikeCount(int postId) async {
    likes = await topicRepository.getLikeCounts(postId);
    // notifyListeners() 제거 - PostCard가 setState로 관리
  }

  Future<void> getCommentCount(int postId) async {
    comments = await topicRepository.getCommentCounts(postId);
    // notifyListeners() 제거 - PostCard가 setState로 관리
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    posts = await repository.getAllPosts();
  }

  Future<void> fetchTopicAndPostsById(int topicId) async {
    _isInitialized = true;

    try {
      final result = await Supabase.instance.client
          .from('topic')
          .select('id, content, uploaded_at')
          .eq('id', topicId)
          .maybeSingle();

      if (result != null) {
        todayTopic = {
          'id': result['id'],
          'content': result['content'],
          'uploaded_at': result['uploaded_at'],
        };

        await fetchPostsByTopicId(topicId);
      } else {
        todayTopic = {'content': "주제를 찾을 수 없습니다"};
        posts = [];
        notifyListeners();
      }
    } catch (e) {
      todayTopic = {'content': "오류 발생"};
      posts = [];
      notifyListeners();
    }
  }
}
