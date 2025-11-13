import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:opicproject/features/post/data/post_repository.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _repository = PostRepository.shared;

  Map<String, dynamic>? post;
  int likeCount = 0;
  bool buttonLike = true;
  String loginUserName = "친구1";
  String postWriter = "친구1";
  File? selectedImage;
  final commentListController = TextEditingController();
  List<Map<String, dynamic>> commentList = [];
  int? _loadedPostId;

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  late String commentDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
  String todayTopic = "겨울풍경";

  Future<void> fetchPostById(int id) async {
    if (_loadedPostId == id && post != null) return;

    post = await _repository.getPostById(id);
    likeCount = await _repository.getLikeCount(id);
    await fetchComments(id);

    _loadedPostId = id;
    notifyListeners();
  }

  Future<void> updatePostImage(int id, String newUrl) async {
    await _repository.updatePostImage(id, newUrl);
    post?['image_url'] = newUrl;
    notifyListeners();
  }

  void setImage(File image) {
    selectedImage = image;
    notifyListeners();
  }

  Future<void> toggleLike(int userId, int postId) async {
    await _repository.toggleLike(userId, postId);
    await fetchLikeCount(postId);
    notifyListeners();
  }

  Future<void> fetchLikeCount(int postId) async {
    likeCount = await _repository.getLikeCount(postId);
    notifyListeners();
  }

  Future<void> addComment(int userId, int postId) async {
    final text = commentListController.text.trim();
    if (text.isEmpty) return;

    await _repository.commentSend(userId, postId, text);

    commentList.add({
      'user_id': userId,
      'post_id': postId,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
      'is_deleted': false,
    });

    commentListController.clear();
    Fluttertoast.showToast(msg: "댓글 작성이 완료되었습니다.");
    notifyListeners();
  }

  Future<void> fetchComments(int postId) async {
    commentList = await _repository.fetchComments(postId);
    notifyListeners();
  }

  void clearPostData() {
    post = null;
    commentList.clear();
    _loadedPostId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    commentListController.dispose();
    super.dispose();
  }
}
