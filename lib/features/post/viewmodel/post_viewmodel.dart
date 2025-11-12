import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
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
  List<String> commentList = [];

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  late String commentDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
  String todayTopic = "겨울풍경";

  Future<void> fetchPostById(int id) async {
    post = await _repository.getPostById(id);
    likeCount = await _repository.getLikeCount(id);
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

  Future<void> toggleLike(int postId) async {
    final userId = SupabaseManager.shared.supabase.auth.currentUser?.id;
    await _repository.fetchLike(userId!, postId);
    likeCount = await _repository.getLikeCount(postId);
    notifyListeners();
  }

  void addComment() {
    if (commentListController.text.isEmpty) return;
    commentList.add(commentListController.text);
    commentListController.clear();
    Fluttertoast.showToast(msg: "댓글 작성이 완료되었습니다.");
    notifyListeners();
  }

  @override
  void dispose() {
    commentListController.dispose();
    super.dispose();
  }
}
