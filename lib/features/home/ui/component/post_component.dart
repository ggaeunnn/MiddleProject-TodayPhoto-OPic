//게시물 컴포넌트
import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/models/post_model.dart';

// import '../../../core/models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //이미지
        Image.network(
          post.imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),

        //좋아요 댓글 부분
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              //좋아요
              const Icon(Icons.favorite, color: AppColors.opicRed, size: 20),
              const SizedBox(width: 4),
              Text(
                'post.likes',
                style: const TextStyle(color: AppColors.opicRed),
              ),

              const SizedBox(width: 16),

              // 댓글
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.opicCoolGrey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'post.comments',
                style: const TextStyle(color: AppColors.opicCoolGrey),
              ),
            ],
          ),
        ),

        //게시글 구분선
        const Divider(height: 2, thickness: 1, color: AppColors.opicSoftBlue),
      ],
    );
  }
}
