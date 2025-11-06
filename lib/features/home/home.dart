import 'package:flutter/material.dart';
import 'package:opicproject/core/models/post_model.dart';
import 'package:opicproject/core/widgets.dart';

class HomeScreen extends StatelessWidget {
  //TODO:뷰모델 사용시 위의 const생성자로 교체
  //const HomeScreen({super.key});
  HomeScreen({super.key});
  //TODO:임시 더미 데이터  나중에 지워야함
  final List<Post> _posts = Post.fixedDummyPosts;

  //TODO:현재 주제 뷰모델 사용시 삭제예정
  final String currentTopic = Post.fixedDummyPosts.isNotEmpty
      ? Post.fixedDummyPosts.first.topic
      : '주제 없음';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OpicAppbar(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //주제 영역
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 주제',
                      style: TextStyle(fontSize: 14, color: Color(0xffd9d9d9)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTopic,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: Color(0xffd9d9d9)),
              ],
            ),
          ),

          //계시물 영역
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Color(0xfffcfcf0)),
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: _posts[index]);
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO: 게시글 작성 페이지 이동 또는 팝업을 통한 선택
        },
        child: const Icon(Icons.edit),
      ),

      bottomNavigationBar: OpicBottomNav(),
    );
  }
}

//계시물 컴포넌트
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //이미지
        Image.network(
          post.imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),

        //좋아요 댓글 부분
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //좋아요
              const Icon(Icons.favorite, color: Color(0xffff826f), size: 20),
              const SizedBox(width: 4),
              Text(
                '${post.likes}',
                style: const TextStyle(color: Color(0xffff826f)),
              ),

              const SizedBox(width: 16),

              // 댓글
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xffccccc8),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.comments}',
                style: const TextStyle(color: Color(0xffccccc8)),
              ),
            ],
          ),
        ),

        //계시글 구분선
        const Divider(height: 20, thickness: 0.7, color: Color(0xff95b7db)),
      ],
    );
  }
}
