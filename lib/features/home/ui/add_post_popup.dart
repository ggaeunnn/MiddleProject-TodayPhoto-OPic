import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:provider/provider.dart';

class addPostPopup extends StatefulWidget {
  const addPostPopup({super.key});

  @override
  State<addPostPopup> createState() => _addPostPopup();
}

class _addPostPopup extends State<addPostPopup> {
  File? selectedImage;
  final pick = ImagePicker();

  Future<void> openGallery() async {
    XFile? pickImage = await pick.pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      setState(() {
        selectedImage = File(pickImage.path);
      });
    }
  }

  File? takePicture;
  final pickCamera = ImagePicker();

  Future<void> camera() async {
    XFile? pickImage = await pickCamera.pickImage(source: ImageSource.camera);
    if (pickImage != null) {
      setState(() {
        takePicture = File(pickImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Color(0xfffefefe),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("게시물 작성", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        "주제: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xff515151),
                        ),
                      ),
                      Text(
                        homeViewModel.todayTopic?['content'] ?? "주제 없음",
                        style: TextStyle(color: Color(0xFF95B7DB)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),
            selectedImage == null && takePicture == null
                ? Container(
                    color: AppColors.opicCoolGrey,
                    height: 350,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Text(
                          "오늘 주제에 맞는 사진을 넣어주세요!",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : selectedImage == null
                ? Image.file(
                    takePicture!,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.fill,
                  )
                : Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.fill,
                  ),

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  openGallery();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffe8e8dc),
                  foregroundColor: Color(0xfffefefe),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  Icons.file_upload_outlined,
                  color: Color(0xff515151),
                ),
                label: Text(
                  "이미지 업로드",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff515151),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  camera();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff95b7db),
                  foregroundColor: Color(0xfffefefe),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.file_upload_outlined),
                label: Text(
                  "새로 찍기",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xfffefefe),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final viewmodel = context.read<PostViewModel>();

                      if (selectedImage == null && takePicture == null) {
                        Fluttertoast.showToast(msg: "이미지를 선택해주세요.");
                        return;
                      }
                      final topicId = homeViewModel.todayTopic?['id'];
                      if (topicId == null) {
                        Fluttertoast.showToast(msg: "주제 정보를 불러올 수 없습니다.");
                        return;
                      }

                      final file = selectedImage ?? takePicture!;

                      final imageUrl = await viewmodel.uploadImageToSupabase(
                        file,
                      );

                      if (imageUrl == null) {
                        Fluttertoast.showToast(msg: "이미지 업로드 실패");
                        return;
                      }
                      await viewmodel.createPost(imageUrl, topicId);
                      await homeViewModel.fetchPostsByTopicId(topicId);

                      context.pop();
                      Fluttertoast.showToast(msg: "게시물이 작성되었습니다.");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff95b7db),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "올리기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xfffefefe),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffe8e8dc),
                      foregroundColor: Color(0xfffefefe),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "닫기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff515151),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
