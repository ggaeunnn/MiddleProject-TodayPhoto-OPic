import 'package:flutter/material.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/feed/ui/component/feed_empty_state.dart';
import 'package:opicproject/features/feed/ui/component/feed_header.dart';
import 'package:opicproject/features/feed/ui/component/feed_post_grid.dart';
import 'package:opicproject/features/feed/viewmodel/feed_viewmodel.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  final int userId;

  const FeedScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final feedViewModel = context.watch<FeedViewModel>();
    final authManager = context.watch<AuthManager>();

    // 현재 로그인한 유저의 아이디
    final loginUserId = authManager.userInfo?.id ?? 0;

    if (_needsInitialization(feedViewModel, loginUserId)) {
      _initializeFeed(context, feedViewModel, loginUserId);
    }

    // 피드 주인인 유저 정보
    final feedUser = feedViewModel.feedUser;

    if (feedUser == null || feedViewModel.isLoading) {
      return _buildLoadingView();
    }

    return Column(
      children: [
        FeedHeader(feedUser: feedUser, loginUserId: loginUserId),
        Expanded(
          child: Container(
            color: AppColors.opicBackground,
            child: _buildPostList(context, feedViewModel, feedUser),
          ),
        ),
      ],
    );
  }

  bool _needsInitialization(FeedViewModel viewModel, int loginUserId) {
    return (!viewModel.isInitialized || viewModel.feedUser?.id != userId) &&
        loginUserId != 0;
  }

  void _initializeFeed(
    BuildContext context,
    FeedViewModel viewModel,
    int loginUserId,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.isLoading ||
          (viewModel.isInitialized && viewModel.feedUser?.id == userId)) {
        return;
      }
      viewModel.initializeFeed(userId, loginUserId);
    });
  }

  Widget _buildLoadingView() {
    return Container(
      color: AppColors.opicBackground,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.opicBlue),
      ),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    FeedViewModel feedViewModel,
    UserInfo feedUser,
  ) {
    final postsCount = feedViewModel.posts.length;
    final isBlocked = feedViewModel.relationState.isBlocked;
    final isBlockedMe = feedViewModel.relationState.isBlockedMe;

    // 차단 상태 확인
    if (isBlocked) {
      return FeedEmptyState(
        message: "차단한 유저의 게시물은 보이지 않아요",
        onRefresh: () => feedViewModel.refresh(feedUser.id),
      );
    }

    if (isBlockedMe) {
      return FeedEmptyState(
        message: "접근 권한이 주어지지 않았어요 😢",
        onRefresh: () => feedViewModel.refresh(feedUser.id),
      );
    }

    if (postsCount == 0) {
      return FeedEmptyState(
        message: "아직 작성한 게시물이 없어요",
        onRefresh: () => feedViewModel.refresh(feedUser.id),
      );
    }

    return FeedPostGrid(
      posts: feedViewModel.posts,
      scrollController: feedViewModel.scrollController,
      onRefresh: () => feedViewModel.refresh(feedUser.id),
    );
  }
}
