import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:provider/provider.dart';

class EditPopup extends StatefulWidget {
  const EditPopup({super.key});

  @override
  State<EditPopup> createState() => _EditPopupState();
}

class _EditPopupState extends State<EditPopup> {
  final pick = ImagePicker();

  Future<void> openGallery() async {
    final pickImage = await pick.pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      context.read<PostViewModel>().setImage(File(pickImage.path));
    }
  }

  Future<void> camera() async {
    final pickImage = await pick.pickImage(source: ImageSource.camera);
    if (pickImage != null) {
      context.read<PostViewModel>().setImage(File(pickImage.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<PostViewModel>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.opicWhite,
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
                  Text("게시물 수정", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        "주제: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.opicBlack,
                        ),
                      ),
                      Text(
                        viewmodel.post?['topic']?['content'] ?? "주제 없음",
                        style: TextStyle(color: AppColors.opicSoftBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            viewmodel.selectedImage == null
                ? (viewmodel.post?['image_url'] != null
                      ? Image.network(
                          viewmodel.post?['image_url'],
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.fill,
                        )
                      : SizedBox())
                : Image.file(
                    viewmodel.selectedImage!,
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
                  backgroundColor: AppColors.opicBackground,
                  foregroundColor: AppColors.opicWhite,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  Icons.file_upload_outlined,
                  color: AppColors.opicBlack,
                ),
                label: Text(
                  "다른 이미지 업로드",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.opicBlack,
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
                  backgroundColor: AppColors.opicSoftBlue,
                  foregroundColor: AppColors.opicWhite,
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
                    color: AppColors.opicWhite,
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
                    onPressed: (viewmodel.selectedImage == null)
                        ? null
                        : () async {
                            if (viewmodel.selectedImage != null) {
                              final newImageUrl = await viewmodel
                                  .uploadImageToSupabase(
                                    viewmodel.selectedImage!,
                                  );

                              if (newImageUrl != null) {
                                await viewmodel.updatePostImage(
                                  viewmodel.post?['id'],
                                  newImageUrl,
                                );

                                showToast("게시물 수정이 완료되었습니다.");
                                context.pop();
                              } else {
                                showToast("이미지 업로드에 실패했습니다.");
                              }
                            } else {
                              showToast("수정할 이미지가 없습니다.");
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.opicSoftBlue,
                      foregroundColor: AppColors.opicWhite,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "수정하기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.opicWhite,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PostViewModel>().setImage(null);
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.opicBackground,
                        foregroundColor: AppColors.opicWhite,
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
                          color: AppColors.opicBlack,
                        ),
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
