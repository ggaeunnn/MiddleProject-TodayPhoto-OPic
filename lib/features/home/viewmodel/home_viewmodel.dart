import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/home/data/home_repository.dart';
import 'package:opicproject/features/post/data/post_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final PostRepository repository = GetIt.instance<PostRepository>();
  final HomeRepository homeRepository = GetIt.instance<HomeRepository>();
  //final HomeRepository topicRepository = HomeRepository.shared;

  List<Map<String, dynamic>> topics = [];
  Map<String, dynamic>? todayTopic;
  int currentTopicIndex = 0;
  bool _isInitialized = false;
  List<Map<String, dynamic>> posts = [];
  bool isLoading = false;
  File? selectedImage;
  String loginUserName = "친구1";

  // postId별로 likes/comments 저장 (중요!)

  Map<int, int> likes = {}; // postId → likeCount
  Map<int, int> comments = {}; // postId → commentCount

  int? topicId;

  HomeViewModel({this.topicId}) {
    if (topicId != null) {
      fetchTopicAndPostsById(topicId!);
    } else {
      initHome();
    }
  }
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

  //게시물 불러오기
  Future<void> fetchPosts() async {
    final id = todayTopic?['id'];

    if (id == null) {
      posts = [];
      notifyListeners();
      return;
    }

    posts = await homeRepository.getPostsByTopicId(id);
    notifyListeners();
  }

  //주제 불러오기
  Future<void> fetchTopics() async {
    todayTopic = await homeRepository.fetchTodayTopic();

    if (todayTopic != null && todayTopic!['id'] != null) {
      await fetchTopicAndPostsById(todayTopic!['id']);
    }
  }

  //홈화면
  Future<void> initHome() async {
    if (_isInitialized) return;
    await fetchTopics();
    await fetchPosts();
    _isInitialized = true;
  }

  //날짜선택시 이동
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

    final result = await SupabaseManager.shared.supabase
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

      await fetchTopicAndPostsById(result['id']);
    } else {
      todayTopic = {'content': "주제 없음"};
      posts = [];
      notifyListeners();
    }
  }

  //주제 선택시 이동
  Future<void> fetchTopicAndPostsById(int topicId) async {
    _isInitialized = true;

    try {
      final result = await SupabaseManager.shared.supabase
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

        posts = await homeRepository.getPostsByTopicId(topicId);
        notifyListeners();
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

  //새로고침
  Future<void> refreshData() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final id = todayTopic?['id'];
    if (id == null) return;

    posts = await homeRepository.getPostsByTopicId(id);
    notifyListeners();
  }

  //좋아요 개수
  Future<void> getLikeCount(int postId) async {
    likes[postId] = await homeRepository.getLikeCounts(postId);
    // notifyListeners() 제거 - PostCard가 setState로 관리
  }

  //댓글 개수
  Future<void> getCommentCount(int postId) async {
    comments[postId] = await homeRepository.getCommentCounts(postId);
    // notifyListeners() 제거 - PostCard가 setState로 관리
  }

  //게시물 추가
  Future<void> createPost(String imageUrl, int topicId) async {
    isLoading = true;
    notifyListeners();
    try {
      final authManager = AuthManager.shared;
      final userId = authManager.userInfo?.id;

      if (userId == null) {
        print("로그인이 필요합니다.");
        return;
      }

      await repository.insertPost(
        userId: userId,
        imageUrl: imageUrl,
        topicId: topicId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setImage(File? image) {
    selectedImage = image;
    notifyListeners();
  }

  //로그인정보
  Future<void> loadLoginUserInfo() async {
    loginUserName = AuthManager.shared.userInfo?.nickname ?? "알수없음";
    notifyListeners();
  }
}
