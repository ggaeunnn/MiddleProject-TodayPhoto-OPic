import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/models/post_model.dart';

class FeedPostGrid extends StatelessWidget {
  final List<Post> posts;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const FeedPostGrid({
    super.key,
    required this.posts,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(6.0),
        controller: scrollController,
        itemCount: posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostThumbnail(context, post);
        },
      ),
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
