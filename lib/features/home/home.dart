import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/home/ui/add_post_popup.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  //TODO:뷰모델 사용시 위의 const생성자로 교체
  const HomeScreen({super.key});
  // HomeScreen({super.key});
  //TODO:임시 더미 데이터  나중에 지워야함
  // final List<Post> _posts = Post.fixedDummyPosts;

  // //TODO:현재 주제 뷰모델 사용시 삭제예정
  // final String currentTopic = Post.fixedDummyPosts.isNotEmpty
  //     ? Post.fixedDummyPosts.first.topic
  //     : '주제 없음';

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<HomeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewmodel.posts.isEmpty) {
        context.read<HomeViewModel>().loadPosts();
      }
    });
    return Container(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //주제 영역
            Container(
              decoration: BoxDecoration(
                color: AppColors.opicWhite,
                border: Border(
                  top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
                  bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 주제',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.opicLightBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // currentTopic,
                          "주제",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: AppColors.opicBlack,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // const Icon(Icons.bookmark_border, color: Colors.grey),
                  ],
                ),
              ),
            ),

            //게시물 영역
            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewmodel.posts.isEmpty) {
                    return const Text("게시물이 없습니다");
                  }
                  return ListView.builder(
                    itemCount: viewmodel.posts.length,
                    itemBuilder: (context, index) {
                      final post = viewmodel.posts[index];
                      return PostCard(post: post);
                    },
                  );
                },
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: AppColors.opicSoftBlue,
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: AppColors.opicLightBlack.withOpacity(0.6),
              builder: (context) => addPostPopup(),
            );
          },
          child: const Icon(Icons.edit, color: AppColors.opicWhite),
        ),
      ),
    );
  }
}

//계시물 컴포넌트
class PostCard extends StatelessWidget {
  // final Post post;
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //이미지
        InkWell(
          onTap: () {
            final postId = post['id'];
            context.go('/post_detail_page/$postId');
          },
          child: Image.network(
            post['image_url'],
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),

        //좋아요 댓글 부분
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //좋아요
              const Icon(Icons.favorite, color: AppColors.opicRed, size: 20),
              const SizedBox(width: 4),
              Text(
                '${post['likes'] ?? 0}',
                style: const TextStyle(color: AppColors.opicRed),
              ),

              const SizedBox(width: 16),

              // 댓글
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.opicCoolGrey,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${post['comments'] ?? 0}',
                style: const TextStyle(color: AppColors.opicCoolGrey),
              ),
            ],
          ),
        ),

        //계시글 구분선
        const Divider(
          height: 20,
          thickness: 0.5,
          color: AppColors.opicSoftBlue,
        ),
      ],
    );
  }
}
