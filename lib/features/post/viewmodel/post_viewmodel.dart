import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/features/post/data/post_repository.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _repository = GetIt.instance<PostRepository>();

  Map<String, dynamic>? post;
  int likeCount = 0;
  bool buttonLike = true;

  File? selectedImage;
  final commentListController = TextEditingController();
  List<Map<String, dynamic>> commentList = [];

  int? friendUserId;
  String postWriter = "";

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);

  //게시물 상세 불러오기
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

  //수정하면 반영하기
  Future<void> updatePostImage(int id, String newUrl) async {
    await _repository.updatePostImage(id, newUrl);
    post?['image_url'] = newUrl;
    notifyListeners();
  }

  //좋아요 하트
  Future<void> toggleLike(int userId, int postId) async {
    await _repository.toggleLike(userId, postId);
    likedPost = !likedPost;
    await fetchLikeCount(postId);
    notifyListeners();
  }

  //좋아요 눌렀는지
  bool likedPost = false;
  Future<void> ifLikedPost(int loginUserId, int postId) async {
    likedPost = await _repository.checkIfLikedPost(loginUserId, postId);
    notifyListeners();
  }

  //좋아요 수
  Future<void> fetchLikeCount(int postId) async {
    likeCount = await _repository.getLikeCount(postId);
    notifyListeners();
  }

  //댓글달기
  Future<void> addComment(int userId, int postId) async {
    final text = commentListController.text.trim();
    if (text.isEmpty) return;

    await _repository.commentSend(userId, postId, text);

    await fetchComments(postId);

    commentListController.clear();
    showToast("댓글 작성이 완료되었습니다.");
    notifyListeners();
  }

  //댓글가져오기
  Future<void> fetchComments(int postId) async {
    commentList = await _repository.fetchComments(postId);
    notifyListeners();
  }

  //댓글창에서 전에 달았던 텍스트 없애기
  @override
  void dispose() {
    commentListController.dispose();
    super.dispose();
  }

  //게시물 삭제
  Future<void> deletePost(int postId) async {
    await _repository.deletePostWithRelations(postId);
    post = null;
    commentList.clear();
    notifyListeners();
  }

  //댓글삭제
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

  void setImage(File? image) {
    selectedImage = image;
    notifyListeners();
  }

  //이미지업로드
}
