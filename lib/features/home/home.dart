import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/home/ui/add_post_popup.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 한 번만 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<HomeViewModel>();

    return RefreshIndicator(
      onRefresh: viewmodel.refreshData,
      child: Container(
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
                    bottom: BorderSide(
                      color: AppColors.opicSoftBlue,
                      width: 0.5,
                    ),
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
                          viewmodel.isToday
                              ? Text(
                                  '오늘의 주제',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.opicCoolGrey,
                                  ),
                                )
                              : Text(
                                  '그날의 주제',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.opicCoolGrey,
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
                                await viewmodel.fetchTopicByDate(selectedDate);
                                Fluttertoast.showToast(
                                  msg: '선택한 날짜: ${selectedDate.toLocal()}',
                                );
                              }
                            },
                            child: Text(
                              viewmodel.todayTopic?['content'] ?? "주제가 없습니다.",
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
                    ],
                  ),
                ),
              ),

              //게시물 영역
              Expanded(
                child: viewmodel.posts.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.opicBackground,
                        ),
                        child: const Center(child: Text("게시물이 없습니다")),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.opicBackground,
                        ),
                        child: ListView.builder(
                          itemCount: viewmodel.posts.length,
                          itemBuilder: (context, index) {
                            final post = viewmodel.posts[index];
                            return PostCard(
                              key: ValueKey(post['id']), // 중요!
                              post: post,
                            );
                          },
                        ),
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
      ),
    );
  }
}

//게시물 컴포넌트 - 이미 StatefulWidget으로 되어있어서 OK
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int likeCount = 0;
  int commentCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final viewModel = context.read<HomeViewModel>();
    final postId = widget.post['id'];

    // 각 포스트별로 독립적으로 좋아요/댓글 수 가져오기
    await viewModel.getLikeCount(postId);
    await viewModel.getCommentCount(postId);

    if (mounted) {
      setState(() {
        likeCount = viewModel.likes;
        commentCount = viewModel.comments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authManager = context.watch<AuthManager>();
    final loginUserId = authManager.userInfo?.id ?? 0;
    final postId = widget.post['id'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //이미지
        InkWell(
          onTap: () {
            if (loginUserId == 0) {
              Fluttertoast.showToast(msg: "로그인 해주세요");
            } else {
              context.go('/post_detail_page/$postId');
            }
          },
          child: Image.network(
            widget.post['image_url'],
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),

        //좋아요 댓글 부분
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _isLoading
              ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.opicSoftBlue,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //좋아요
                    const Icon(
                      Icons.favorite,
                      color: AppColors.opicRed,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$likeCount",
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
                      "$commentCount",
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
