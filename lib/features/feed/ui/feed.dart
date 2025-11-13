import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/page_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/data/feed_viewmodel.dart';
import 'package:opicproject/features/friend/data/friend_view_model.dart';
import 'package:opicproject/features/post/ui/post_detail_page.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  final int userId;

  const FeedScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (context, feedViewModel, child) {
        final pageViewModel = context.read<PageCountViewmodel>();
        final loginUserId = AuthManager.shared.userInfo?.id ?? 0;
        final feedUserId = pageViewModel.currentPage == 2
            ? loginUserId
            : userId;

        // 빌드 후에 데이터 로드 (한 번만 실행되도록)
        if (feedViewModel.feedUser == null ||
            feedViewModel.feedUser!.id != feedUserId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            feedViewModel.fetchAUser(feedUserId);
            feedViewModel.fetchPosts(1, feedUserId);
          });
        }

        final feedUser = feedViewModel.feedUser;

        if (feedUser == null ||
            (feedViewModel.isLoading && feedViewModel.posts.isEmpty)) {
          return Container(
            color: AppColors.opicBackground,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.opicBlue),
            ),
          );
        }

        return Column(
          children: [
            _buildUserHeader(context, feedViewModel, feedUser, loginUserId),
            Expanded(
              child: Container(
                color: AppColors.opicBackground,
                child: _postList(context, feedViewModel, feedUser),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildUserHeader(
  BuildContext context,
  FeedViewModel feedViewModel,
  UserInfo feedUser,
  int loginUserId,
) {
  final isMyFeed = feedUser.id == loginUserId;

  // 초기 로드 시 한 번만 체크
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!isMyFeed) {
      feedViewModel.checkIfBlocked(loginUserId, feedUser.id);
      context.read<FriendViewModel>().checkIfFriend(loginUserId, feedUser.id);
    }
  });

  return Consumer2<FeedViewModel, FriendViewModel>(
    builder: (context, feedVM, friendVM, child) {
      final isBlocked = feedVM.isBlocked;
      final isFriend = friendVM.isFriend;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.opicWhite,
          border: Border(
            top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
            bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
          ),
        ),
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 닉네임
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  feedUser.nickname,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.opicBlack,
                  ),
                ),
              ),
              // 내 피드가 아닐 때만 버튼 표시
              if (!isMyFeed)
                Row(
                  spacing: 8,
                  children: [
                    // 친구 추가 버튼 (친구가 아니고 차단 안 되어있을 때)
                    if (!isFriend && !isBlocked)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.6),
                            builder: (context) => YesOrClosePopUp(
                              title: "친구가 되시겠어요?",
                              text: "상대방이 친구 요청을 수락하면, 친구가 되어요",
                              confirmText: "친구 요청",
                              onConfirm: () {
                                context.pop();
                                friendVM.makeARequest(loginUserId, feedUser.id);
                                showToast("친구 요청을 보냈어요 💌");
                              },
                              onCancel: () {
                                context.pop();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.opicBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_add_alt_rounded,
                                color: AppColors.opicWhite,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "친구 추가",
                                style: TextStyle(
                                  color: AppColors.opicWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // 차단 버튼 (차단 안 되어있을 때)
                    if (!isBlocked)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.6),
                            builder: (context) => YesOrClosePopUp(
                              title: "차단하시겠어요?",
                              text: "앞으로 차단한 사용자의 게시물은 보이지 않아요",
                              confirmText: "차단하기",
                              onConfirm: () async {
                                context.pop();
                                await feedVM.blockUser(
                                  loginUserId,
                                  feedUser.id,
                                );
                                // 상태 다시 체크
                                await feedVM.checkIfBlocked(
                                  loginUserId,
                                  feedUser.id,
                                );
                                showToast("사용자를 차단했어요");
                              },
                              onCancel: () {
                                context.pop();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.opicRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.block_rounded,
                                color: AppColors.opicWhite,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "차단",
                                style: TextStyle(
                                  color: AppColors.opicWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // 차단 해제 버튼 (차단되어있을 때)
                    if (isBlocked)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.6),
                            builder: (context) => YesOrClosePopUp(
                              title: "차단을 해제하시겠어요?",
                              text: "해당 사용자의 게시물이 다시 보여요",
                              confirmText: "차단해제",
                              onConfirm: () async {
                                context.pop();
                                await feedVM.unblockUser(
                                  loginUserId,
                                  feedUser.id,
                                );
                                // 상태 다시 체크
                                await feedVM.checkIfBlocked(
                                  loginUserId,
                                  feedUser.id,
                                );
                                showToast("사용자를 차단해제했어요");
                              },
                              onCancel: () {
                                context.pop();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.opicCoolGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.opicWhite,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "차단해제",
                                style: TextStyle(
                                  color: AppColors.opicWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _postList(
  BuildContext context,
  FeedViewModel feedViewModel,
  UserInfo feedUser,
) {
  final postsCount = feedViewModel.posts.length;
  final posts = feedViewModel.posts;

  if (postsCount == 0) {
    return RefreshIndicator(
      onRefresh: () => feedViewModel.refresh(feedUser.id),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.opicBackground,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Text(
              "아직 작성한 게시물이 없어요",
              style: TextStyle(fontSize: 16, color: AppColors.opicBlack),
            ),
          ),
        ),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () => feedViewModel.refresh(feedUser.id),
    child: GridView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(6.0),
      controller: feedViewModel.scrollController,
      itemCount: postsCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6.0,
        mainAxisSpacing: 6.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            context.push('/post_detail_page/${post.id}');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.opicWarmGrey,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.opicCoolGrey,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.opicWarmGrey,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.opicBlue,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}
