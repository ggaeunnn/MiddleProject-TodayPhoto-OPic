import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class PostViewModel extends ChangeNotifier {
  int likeCount = 0;
  bool buttonLike = true;
  bool buttonReport = true;
  String loginUserName = "친구1";
  String postWriter = "친구1";
  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  late String commentDate = DateFormat('yyyy-MM-dd hh-mm').format(now);
  String todayTopic = "겨울풍경";
  List<String> commentList = [];
  final commentListController = TextEditingController();
  File? selectedImage;

  //사진 선택
  void setImage(File image) {
    selectedImage = image;
    notifyListeners();
  }

  //좋아요
  void toggleLike() {
    buttonLike = !buttonLike;
    buttonLike ? likeCount-- : likeCount++;
    notifyListeners();
  }

  //댓글
  void addComment() {
    if (commentListController.text.isEmpty) return;
    commentList.add(commentListController.text);
    commentListController.clear();
    Fluttertoast.showToast(msg: "댓글작성이 완료되었습니다.");
    notifyListeners();
  }

  @override
  void dispose() {
    commentListController.dispose();
    super.dispose();
  }
}
