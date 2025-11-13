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

  const PostDetailScreen({required this.postId, super.key});
  Widget build(BuildContext context) {
    final viewmodel = context.watch<PostViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewmodel.fetchPostById(postId);
      viewmodel.loadLoginUserInfo();
      viewmodel.fetchPostWriterId(postId);
    });

    final thisPost = viewmodel.thisPost;
    final postWriter = thisPost?.userId ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  context.go('/home');
                },
                icon: Icon(Icons.keyboard_backspace),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              context.go('/home/feed/$postWriter');
                            },
                            child: Text(
                              viewmodel.postWriter,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Spacer(),
                          Text(
                            viewmodel.formattedDate,
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF515151),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Image.network(
                        viewmodel.post?['image_url'] ??
                            'https://images.unsplash.com/photo-1455156218388-5e61b526818b?auto=format&fit=crop&q=60&w=500',
                        width: double.infinity,
                        height: 350,
                        fit: BoxFit.fill,
                      ),

                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              (viewmodel.buttonLike)
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                            ),
                            iconSize: 20,
                            color: AppColors.opicRed,
                            onPressed: () {
                              final loginUserId =
                                  AuthManager.shared.userInfo?.id ?? 0;

                              viewmodel.toggleLike(loginUserId, postId);

                              // 버튼 아이콘 토글
                              viewmodel.buttonLike = !viewmodel.buttonLike;
                            },
                          ),
                          Text(
                            "좋아요 ${viewmodel.likeCount} ",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.opicBlack,
                            ),
                          ),
                          Spacer(),

                          // 내 게시물이라면 수정하기/삭제하기
                          (viewmodel.loginUserName == viewmodel.postWriter)
                              ? Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.opicSoftBlue,
                                        fixedSize: Size(110, 10),
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
                                          builder: (context) => EditPopup(),
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
                                    Padding(padding: EdgeInsets.all(5)),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.opicRed,
                                        fixedSize: Size(110, 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: AppColors.opicRed
                                              .withOpacity(0.6),
                                          builder: (context) => DeletePopup(
                                            // currentNickname: loginUser.nickname,
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
                              :
                                // 다른 사람 게시물이라면 신고하기
                                TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(
                                        0.6,
                                      ),
                                      builder: (context) => PostReportScreen(),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.outlined_flag,
                                    color: AppColors.opicRed,
                                  ),
                                  label: Text('신고하기'),
                                ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Text(
                            "주제:",
                            style: TextStyle(color: AppColors.opicLightBlack),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/home');
                            },
                            child: Text(
                              viewmodel.todayTopic,
                              style: TextStyle(color: AppColors.opicSoftBlue),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        color: AppColors.opicBackground,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("댓글"),
                                ),
                                Text(
                                  " ${viewmodel.commentList.length}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Center(
                              child: (viewmodel.commentList.isEmpty)
                                  ? Text("첫 댓글을 남겨보세요!")
                                  : ListView.builder(
                                      itemCount: viewmodel.commentList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final comment =
                                            viewmodel.commentList[index];
                                        return Container(
                                          padding: EdgeInsets.only(left: 10),
                                          width: 100,
                                          color: AppColors.opicWhite,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      // context.go();
                                                    },
                                                    icon: Icon(Icons.person),
                                                  ),
                                                  //이름 바꾸기
                                                  Text(
                                                    comment['user']?['nickname'],
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    comment['created_at']
                                                            ?.toString()
                                                            .split('T')
                                                            .first ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.opicBlack,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right: 8,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  left: 20,
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
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),

              //댓글 입력 창
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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

                  Padding(padding: EdgeInsets.only(left: 10)),
                  Container(
                    alignment: Alignment.center,
                    width: 35,
                    height: 35,
                    color: AppColors.opicSoftBlue,
                    child: IconButton(
                      icon: Icon(Icons.send),
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
