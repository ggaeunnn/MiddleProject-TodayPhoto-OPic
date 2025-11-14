import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/home/ui/add_post_popup.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<HomeViewModel>();
    final homeViewmodel = context.watch<HomeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initHome();
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
                        //데이트피커
                        GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (selectedDate != null) {
                              await homeViewmodel.fetchTopicByDate(
                                selectedDate,
                              );
                              Fluttertoast.showToast(
                                msg: '선택한 날짜: ${selectedDate.toLocal()}',
                              );
                            }
                          },
                          child: Text(
                            homeViewmodel.todayTopic?['content'] ?? "주제가 없습니다.",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: AppColors.opicBlack,
                            ),
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
              child: viewmodel.posts.isEmpty
                  ? const Center(child: Text("게시물이 없습니다"))
                  : ListView.builder(
                      itemCount: viewmodel.posts.length,
                      itemBuilder: (context, index) {
                        final post = viewmodel.posts[index];
                        return PostCard(post: post);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: viewmodel.isToday
            ? FloatingActionButton(
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
              )
            : null,
      ),
    );
  }
}

//게시물 컴포넌트
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authManager = context.watch<AuthManager>();
    final loginUserId = authManager.userInfo?.id ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //이미지
        InkWell(
          onTap: () {
            if (loginUserId == 0) {
              Fluttertoast.showToast(msg: "로그인 해주세요");
            } else {
              final postId = post['id'];
              context.go('/post_detail_page/$postId');
            }
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

        //게시글 구분선
        const Divider(
          height: 20,
          thickness: 0.5,
          color: AppColors.opicSoftBlue,
        ),
      ],
    );
  }
}
