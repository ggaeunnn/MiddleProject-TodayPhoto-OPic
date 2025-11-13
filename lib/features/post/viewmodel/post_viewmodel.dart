import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/post/data/post_repository.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _repository = PostRepository.shared;

  Map<String, dynamic>? post;
  int likeCount = 0;
  bool buttonLike = true;
  String loginUserName = "친구1";

  File? selectedImage;
  final commentListController = TextEditingController();
  List<Map<String, dynamic>> commentList = [];

  int? friendUserId;
  String postWriter = "";

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  String todayTopic = "겨울풍경";

  Future<void> fetchPostById(int id) async {
    post = await _repository.getPostById(id);

    friendUserId = post?['user']?['id'];
    postWriter = post?['user']?['nickname'] ?? "이름 없음";

    final created = post?['created_at'];
    if (created != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(created));
    }

    likeCount = await _repository.getLikeCount(id);
    await fetchComments(id);

    notifyListeners();
  }

  Future<void> updatePostImage(int id, String newUrl) async {
    await _repository.updatePostImage(id, newUrl);
    post?['image_url'] = newUrl;
    notifyListeners();
  }

  void setImage(File? image) {
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

    await fetchComments(postId);

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
    notifyListeners();
  }

  @override
  void dispose() {
    commentListController.dispose();
    super.dispose();
  }

  Future<void> loadLoginUserInfo() async {
    loginUserName = AuthManager.shared.userInfo?.nickname ?? "알수없음";
    notifyListeners();
  }

  Future<int?> createPost(String imageUrl) async {
    final userId = AuthManager.shared.userInfo?.id;

    if (userId == null) {
      print("로그인된 사용자 없음");
      return null;
    }

    final id = await _repository.insertPost(userId: userId, imageUrl: imageUrl);
    return id;
  }

  Future<String?> uploadImageToSupabase(File file) async {
    final supabase = SupabaseManager.shared.supabase;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('post_images').upload(fileName, file);

    return supabase.storage.from('post_images').getPublicUrl(fileName);
  }

  Future<void> deletePost(int postId) async {
    await _repository.deletePostWithRelations(postId);
    clearPostData();
  }
}
