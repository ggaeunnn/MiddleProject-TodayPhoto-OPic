//feed page
import 'package:flutter/material.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/features/feed/viewmodel/feed_viewmodel.dart';
import 'package:provider/provider.dart';

class MyFeedScreen extends StatelessWidget {
  const MyFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (builder, viewmodel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        viewmodel.isMyFeed
                            ? '내 피드'
                            : viewmodel.nickname, // 내 피드면 '내 피드', 아니면 유저 닉네임
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // '차단하기' Chip: 내 피드가 아닐 때만 표시
                      if (!viewmodel.isMyFeed)
                        Chip(
                          label: const Text('차단하기'),
                          backgroundColor: Colors.pink[50],
                          labelStyle: TextStyle(
                            color: Colors.pink[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide.none,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          visualDensity: const VisualDensity(
                            horizontal: 0,
                            vertical: -4,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 게시물 수 및 좋아요 수
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  Text(
                    '게시물 ${viewmodel.postCount}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '좋아요 ${viewmodel.likeCount}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // 타일형 이미지 섹션 (GridView)
            Expanded(child: FeedContent()),
          ],
        );
      },
    );
  }
}

class FeedContent extends StatelessWidget {
  const FeedContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedViewModel>(
      builder: (context, viewmodel, child) {
        final List<Post> posts = viewmodel.feed;
        final bool isMyFeed = viewmodel.isMyFeed;

        if (posts.isEmpty) {
          return Container(
            color: const Color(0xFFF7F4EC),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '아직 게시물이 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // isMyFeed가 true일 때만 버튼을 표시합니다.
                  if (isMyFeed)
                    ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7D7E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '첫 게시물 작성하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];

              return Image.network(
                post.imageUrl, // 뷰모델 게시물 객체의 URL 사용
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Text('이미지 로드 실패')),
                ),
              );
            },
          );
        }
      },
    );
  }
}
