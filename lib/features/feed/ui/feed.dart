import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/page_model.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/data/feed_viewmodel.dart';
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
          // 내 피드가 아닐 때만 차단 버튼 표시
          if (!isMyFeed)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('사용자 차단'),
                    content: Text('${feedUser.nickname}님을 차단하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await feedViewModel.blockUser(feedUser.id);
                          if (context.mounted) {
                            context.pop(); // 다이얼로그 닫기
                            context.pop(); // 피드 화면 닫기
                          }
                        },
                        child: Text(
                          '차단',
                          style: TextStyle(color: AppColors.opicRed),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ],
      ),
    ),
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
