import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/home/data/home_repository.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:provider/provider.dart';

class addPostPopup extends StatefulWidget {
  const addPostPopup({super.key, required this.viewModel});
  final HomeViewModel viewModel;
  @override
  State<addPostPopup> createState() => _addPostPopup();
}

class _addPostPopup extends State<addPostPopup> {
  File? selectedImage;
  final HomeRepository repository = GetIt.instance<HomeRepository>();
  final pick = ImagePicker();
  late HomeViewModel viewmodel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewmodel = widget.viewModel;
  }

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
    final postViewmodel = context.watch<PostViewModel>();

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
                  Text("게시물 작성", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        viewmodel.todayTopic?['content'] ?? "주제 없음",
                        style: TextStyle(color: AppColors.opicSoftBlue),
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
                        Image.network(
                          'https://images.unsplash.com/photo-1455156218388-5e61b526818b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFQSVCMiVBOCVFQyU5QSVCOHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.fill,
                        ),
                        // Text(
                        //   "오늘 주제에 맞는 사진을 넣어주세요!",
                        //   textAlign: TextAlign.center,
                        // ),
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
                  backgroundColor: AppColors.opicWarmGrey,
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
                  "이미지 선택",
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
                    onPressed: (selectedImage == null && takePicture == null)
                        ? null
                        : () async {
                            final postViewmodel = context.read<PostViewModel>();

                            if (selectedImage == null && takePicture == null) {
                              showToast("이미지를 선택해주세요.");
                              return;
                            }
                            final topicId = viewmodel.todayTopic?['id'];
                            if (topicId == null) {
                              showToast("주제 정보를 불러올 수 없습니다.");
                              return;
                            }

                            final file = selectedImage ?? takePicture!;
                            final imageUrl =
                                await GetIt.instance<HomeRepository>()
                                    .uploadImageToSupabase(file);

                            if (imageUrl == null) {
                              showToast("이미지 업로드 실패");
                              return;
                            }
                            await viewmodel.createPost(imageUrl, topicId);
                            await viewmodel.fetchTopicAndPostsById(topicId);

                            context.pop();
                            showToast("게시물이 작성되었습니다.");
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.opicSoftBlue,
                      foregroundColor: AppColors.opicWhite,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: viewmodel.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              strokeCap: StrokeCap.round,
                              color: AppColors.opicWhite,
                            ),
                          )
                        : const Text(
                            "업로드",
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
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.opicWarmGrey,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
