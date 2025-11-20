import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/features/feed/viewmodel/feed_viewmodel.dart';
import 'package:provider/provider.dart';

class FeedPostGrid extends StatelessWidget {
  final List<Post> posts;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool isLastPage;

  const FeedPostGrid({
    super.key,
    required this.posts,
    required this.scrollController,
    required this.onRefresh,
    this.onLoadMore,
    this.isLoading = false,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(6.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (onLoadMore != null && index == posts.length - 6) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onLoadMore?.call();
                      });
                    }

                    final post = posts[index];
                    return _buildPostThumbnail(context, post);
                  }, childCount: posts.length),
                ),
              ),
              if (isLoading && !isLastPage)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.opicBlue,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostThumbnail(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () => context.push('/post_detail_page/${post.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          post.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildErrorPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.opicWarmGrey,
      child: Icon(Icons.image_not_supported, color: AppColors.opicCoolGrey),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.opicWarmGrey,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.opicBlue,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
