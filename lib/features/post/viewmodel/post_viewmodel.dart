import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/post/data/post_repository.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _repository = PostRepository.shared;

  Map<String, dynamic>? post;
  int likeCount = 0;
  bool buttonLike = true;
  String loginUserName = "친구1";
  bool isLoading = false;
  bool likedPost = false;

  File? selectedImage;
  final commentListController = TextEditingController();
  List<Map<String, dynamic>> commentList = [];

  int? friendUserId;
  String postWriter = "";

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);

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
    likedPost = !likedPost;
    await fetchLikeCount(postId);
    notifyListeners();
  }

  Future<void> ifLikedPost(int loginUserId, int postId) async {
    likedPost = await _repository.checkIfLikedPost(loginUserId, postId);
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
    showToast("댓글 작성이 완료되었습니다.");
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

      await _repository.insertPost(
        userId: userId,
        imageUrl: imageUrl,
        topicId: topicId,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

  Future<void> deleteComment(int commentId) async {
    try {
      await SupabaseManager.shared.supabase
          .from('comments')
          .delete()
          .eq('id', commentId);

      commentList.removeWhere((comment) => comment['id'] == commentId);
      notifyListeners();
      showToast("댓글이 삭제되었습니다.");
    } catch (e) {
      print("댓글 삭제 실패: $e");
      showToast("댓글 삭제에 실패했습니다.");
    }
  }
}
