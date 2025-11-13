import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:provider/provider.dart';

class DeletePopup extends StatelessWidget {
  final int postId;

  const DeletePopup({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xfffefefe),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("게시물 삭제", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text(
                    "정말 게시물을 삭제하시겠습니까?",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xff515151),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<PostViewModel>().deletePost(postId);

                      Navigator.pop(context);
                      context.go('/home');
                      _showToast(context, "게시물이 삭제되었습니다.");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff95b7db),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "삭제하기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xfffefefe),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe8e8dc),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
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

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.opicBlue,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
