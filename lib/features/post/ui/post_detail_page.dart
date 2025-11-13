import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/post/ui/post_delete_popup.dart';
import 'package:opicproject/features/post/ui/post_edit_popup.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:opicproject/features/post_report/ui/post_report_page.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<PostViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewmodel.fetchPostById(postId);
      viewmodel.loadLoginUserInfo();
    });

    final postWriterUserId = viewmodel.friendUserId ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.keyboard_backspace),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              context.go('/home/feed/$postWriterUserId');
                            },
                            child: Text(
                              viewmodel.postWriter,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            viewmodel.formattedDate,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF515151),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Post Image
                      Image.network(
                        viewmodel.post?['image_url'],
                        width: double.infinity,
                        height: 350,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              viewmodel.buttonLike
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                            ),
                            iconSize: 20,
                            color: AppColors.opicRed,
                            onPressed: () {
                              final loginUserId =
                                  AuthManager.shared.userInfo?.id ?? 0;
                              viewmodel.toggleLike(loginUserId, postId);
                              viewmodel.buttonLike = !viewmodel.buttonLike;
                            },
                          ),
                          Text(
                            "좋아요 ${viewmodel.likeCount}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.opicBlack,
                            ),
                          ),
                          const Spacer(),
                          (AuthManager.shared.userInfo?.id ==
                                  viewmodel.friendUserId)
                              ? Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.opicSoftBlue,
                                        fixedSize: const Size(110, 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: AppColors.opicLightBlack
                                              .withOpacity(0.6),
                                          builder: (context) =>
                                              const EditPopup(),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppColors.opicWhite,
                                        size: 13,
                                      ),
                                      label: Text(
                                        "수정하기",
                                        style: TextStyle(
                                          color: AppColors.opicWhite,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.opicRed,
                                        fixedSize: const Size(110, 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.black
                                              .withOpacity(0.6),
                                          builder: (_) => DeletePopup(
                                            postId: viewmodel.post?['id'] ?? 0,
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: AppColors.opicWhite,
                                        size: 13,
                                      ),
                                      label: Text(
                                        "삭제하기",
                                        style: TextStyle(
                                          color: AppColors.opicWhite,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(
                                        0.6,
                                      ),
                                      builder: (context) => PostReportScreen(
                                        postId: viewmodel.post?['id'] ?? 0,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.outlined_flag,
                                    color: AppColors.opicRed,
                                  ),
                                  label: const Text('신고하기'),
                                ),
                        ],
                      ),
                      const Divider(),

                      Row(
                        children: [
                          Text(
                            "주제:",
                            style: TextStyle(color: AppColors.opicLightBlack),
                          ),
                          TextButton(
                            onPressed: () => context.go('/home'),
                            child: Text(
                              viewmodel.todayTopic,
                              style: TextStyle(color: AppColors.opicSoftBlue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        color: AppColors.opicBackground,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("댓글"),
                                ),
                                Text(
                                  "${viewmodel.commentList.length}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: viewmodel.commentList.isEmpty
                                  ? const Text("첫 댓글을 남겨보세요!")
                                  : ListView.builder(
                                      itemCount: viewmodel.commentList.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final comment =
                                            viewmodel.commentList[index];

                                        final loginUserNickname =
                                            AuthManager
                                                .shared
                                                .userInfo
                                                ?.nickname ??
                                            '';
                                        final commentWriterNickname =
                                            comment['user']?['nickname'] ?? '';

                                        return Container(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          color: AppColors.opicWhite,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons.person,
                                                    ),
                                                  ),
                                                  Text(commentWriterNickname),
                                                  const Spacer(),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        comment['created_at']
                                                                ?.toString()
                                                                .split('T')
                                                                .first ??
                                                            '',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .opicBlack,
                                                        ),
                                                      ),
                                                      if (loginUserNickname ==
                                                          commentWriterNickname)
                                                        ElevatedButton.icon(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .opicRed,
                                                            fixedSize:
                                                                const Size(
                                                                  110,
                                                                  10,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            final commentId =
                                                                comment['id'];
                                                            viewmodel
                                                                .deleteComment(
                                                                  commentId,
                                                                );
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: AppColors
                                                                .opicWhite,
                                                            size: 13,
                                                          ),
                                                          label: Text(
                                                            "삭제하기",
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .opicWhite,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                  left: 20,
                                                  bottom: 8,
                                                ),
                                                width: double.infinity,
                                                child: Text(
                                                  comment['text'] ?? '',
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 35,
                      color: AppColors.opicWhite,
                      child: TextField(
                        controller: viewmodel.commentListController,
                        decoration: InputDecoration(
                          hintText: "댓글을 입력하세요..",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.opicLightBlack,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    alignment: Alignment.center,
                    width: 35,
                    height: 35,
                    color: AppColors.opicSoftBlue,
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      iconSize: 20,
                      color: AppColors.opicWhite,
                      onPressed: () {
                        final loginUserId =
                            AuthManager.shared.userInfo?.id ?? 0;
                        viewmodel.addComment(loginUserId, postId);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showToast(String content) {
  Fluttertoast.showToast(
    msg: content,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: AppColors.opicBlue,
    fontSize: 14,
    textColor: AppColors.opicWhite,
    toastLength: Toast.LENGTH_SHORT,
  );
}
