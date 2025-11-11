import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
                  Text("게시물 수정", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Text("겨울풍경", style: TextStyle(color: Color(0xFF95B7DB))),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            viewmodel.selectedImage == null
                ? Image.network(
                    'https://images.unsplash.com/photo-1455156218388-5e61b526818b?ixlib=rb-4.1.0&auto=format&fit=crop&q=60&w=500',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.fill,
                  )
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
                  "다른 이미지 업로드",
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
                    onPressed: () {
                      context.pop();
                      showToast("게시물 수정이 완료되었습니다.");
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
                      "수정하기",
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
