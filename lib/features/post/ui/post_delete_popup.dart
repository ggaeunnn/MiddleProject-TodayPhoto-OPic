import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
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
            const SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      final viewmodel = context.read<PostViewModel>();

                      await viewmodel.deletePost(postId);

                      Fluttertoast.showToast(msg: "게시물이 삭제되었습니다.");

                      if (context.mounted) {
                        context.go('/home');
                      }
                    },
                    child: const Text("삭제하기"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text("닫기"),
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
