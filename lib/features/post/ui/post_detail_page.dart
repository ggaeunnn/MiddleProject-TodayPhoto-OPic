import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/home/viewmodel/home_viewmodel.dart';
import 'package:opicproject/features/post/component/edit_menu_widget.dart';
import 'package:opicproject/features/post/ui/post_delete_popup.dart';
import 'package:opicproject/features/post/ui/post_edit_popup.dart';
import 'package:opicproject/features/post/viewmodel/post_viewmodel.dart';
import 'package:opicproject/features/post_report/ui/post_report_page.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadData();
        _isInitialized = true;
      }
    });
  }

  Future<void> _loadData() async {
    final viewmodel = context.read<PostViewModel>();
    final homeViewmodel = context.read<HomeViewModel>();
    final authManager = context.read<AuthManager>();
    final loginUserId = authManager.userInfo?.id ?? 0;

    await Future.wait([
      viewmodel.fetchPostById(widget.postId),
      homeViewmodel.loadLoginUserInfo(),
      viewmodel.fetchLikeCount(widget.postId),
      viewmodel.ifLikedPost(loginUserId, widget.postId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = context.watch<PostViewModel>();
    final authManager = context.read<AuthManager>();
    final homeViewmodel = context.watch<HomeViewModel>();
    final loginUserId = authManager.userInfo?.id ?? 0;

    final postWriterUserId = viewmodel.friendUserId ?? 0;

    final imageUrl = viewmodel.post?['image_url'] ?? '';
    final currentPostId = viewmodel.post?['id'] ?? 0;

    if (viewmodel.post == null) {
      return Scaffold(
        body: SafeArea(
          child: Container(
            color: AppColors.opicBackground,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.opicBlue),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: AppColors.opicBackground),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opicWhite,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.opicSoftBlue,
                                width: 0.5,
                              ),
                              bottom: BorderSide(
                                color: AppColors.opicSoftBlue,
                                width: 0.5,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 5.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Back Button
                                  IconButton(
                                    onPressed: () => context.go('/home'),
                                    icon: const Icon(Icons.keyboard_backspace),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.go(
                                        '/home/feed/$postWriterUserId',
                                      );
                                    },
                                    child: Text(
                                      viewmodel.postWriter,
                                      style: const TextStyle(
                                        color: AppColors.opicSoftBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Text(
                                  viewmodel.formattedDate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.opicBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opicBackground,
                          ),
                          child: // Post Image
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.network(
                              viewmodel.post?['image_url'],
                              width: double.infinity,
                              height: 350,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opicBackground,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.opicSoftBlue,
                                width: 0.2,
                              ),
                              bottom: BorderSide(
                                color: AppColors.opicSoftBlue,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            viewmodel.likedPost
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                          ),
                                          iconSize: 20,
                                          color: AppColors.opicRed,
                                          onPressed: () async {
                                            final loginUserId =
                                                AuthManager
                                                    .shared
                                                    .userInfo
                                                    ?.id ??
                                                0;
                                            await viewmodel.toggleLike(
                                              loginUserId,
                                              widget.postId,
                                            );
                                          },
                                        ),
                                        Text(
                                          "좋아요 ${viewmodel.likeCount}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.opicBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                    (AuthManager.shared.userInfo?.id ==
                                            viewmodel.friendUserId)
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.more_horiz,
                                              color: AppColors.opicBlack,
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    AppColors.opicWarmGrey,
                                                builder: (context) => EditMenu(
                                                  options: [
                                                    MenuOption(
                                                      icon: Icons.edit_rounded,
                                                      text: '수정하기',
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierColor: AppColors
                                                              .opicLightBlack
                                                              .withOpacity(0.6),
                                                          builder: (context) =>
                                                              const EditPopup(),
                                                        );
                                                      },
                                                    ),
                                                    MenuOption(
                                                      icon:
                                                          Icons.delete_rounded,
                                                      text: '삭제하기',
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierColor: Colors
                                                              .black
                                                              .withOpacity(0.6),
                                                          builder: (_) =>
                                                              DeletePopup(
                                                                postId:
                                                                    viewmodel
                                                                        .post?['id'] ??
                                                                    0,
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : TextButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                barrierColor: Colors.black
                                                    .withOpacity(0.6),
                                                builder: (context) =>
                                                    PostReportScreen(
                                                      postId:
                                                          viewmodel
                                                              .post?['id'] ??
                                                          0,
                                                    ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.outlined_flag,
                                              color: AppColors.opicCoolGrey,
                                            ),
                                            label: const Text(
                                              '신고하기',
                                              style: TextStyle(
                                                color: AppColors.opicCoolGrey,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opicBackground,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.opicSoftBlue,
                                width: 0.2,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "주제:",
                                  style: TextStyle(
                                    color: AppColors.opicCoolGrey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final topicId = viewmodel.post?['topic_id'];

                                    if (topicId != null) {
                                      context.go('/home?topicId=$topicId');
                                    } else {
                                      showToast("주제가 없습니다.");
                                    }
                                  },
                                  child: Text(
                                    viewmodel.post?['topic']?['content'] ??
                                        "주제 없음",

                                    style: TextStyle(
                                      color: AppColors.opicSoftBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: AppColors.opicBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                      ? const Text(
                                          "첫 댓글을 남겨보세요!",
                                          style: TextStyle(
                                            color: AppColors.opicCoolGrey,
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount:
                                              viewmodel.commentList.length,
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
                                                comment['user']?['nickname'] ??
                                                '';

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 1.0,
                                                  ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.opicWhite
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(20.0),
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors
                                                          .opicSoftBlue,
                                                      width: 0.3,
                                                    ),
                                                  ),
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
                                                          Text(
                                                            commentWriterNickname,
                                                          ),
                                                          SizedBox(width: 8),
                                                          // const Spacer(),
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  comment['created_at']
                                                                          ?.toString()
                                                                          .split(
                                                                            'T',
                                                                          )
                                                                          .first ??
                                                                      '',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: AppColors
                                                                        .opicBlack,
                                                                  ),
                                                                ),
                                                                if (loginUserNickname ==
                                                                    commentWriterNickname)
                                                                  IconButton(
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
                                                                          .cancel_outlined,
                                                                      color: AppColors
                                                                          .opicRed,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 20,
                                                              bottom: 8,
                                                            ),
                                                        width: double.infinity,
                                                        child: Text(
                                                          comment['text'] ?? '',
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.opicSoftBlue,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            color: AppColors.opicWhite,
                            child: TextField(
                              controller: viewmodel.commentListController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                hintText: "댓글을 입력하세요..",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.opicLightBlack,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opicSoftBlue,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            iconSize: 20,
                            color: AppColors.opicWhite,
                            onPressed: () {
                              final loginUserId =
                                  AuthManager.shared.userInfo?.id ?? 0;
                              viewmodel.addComment(loginUserId, widget.postId);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
