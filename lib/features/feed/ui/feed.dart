//feed page
import 'package:flutter/material.dart';

class MyFeedScreen extends StatelessWidget {
  const MyFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ShellRoute에서는 뒤로가기 버튼 제거
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          '오늘 한장',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
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
                    const Text(
                      '내 피드',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
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

                // 오른쪽 상단 그리드/리스트 뷰 아이콘
              ],
            ),
          ),

          // 게시물 수 및 좋아요 수
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: Row(
              children: const [
                Text('게시물 3', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Text('좋아요 1', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // 타일형 이미지 섹션 (GridView)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemCount: 3, //갯수
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 한 줄에 3개
                crossAxisSpacing: 4.0, //가로 간격
                mainAxisSpacing: 4.0, //세로 간격
                childAspectRatio: 1.0, // 타일 비율 (정사각형)
              ),
              itemBuilder: (context, index) {
                //임시 이미지 리스트 3개
                final List<String> imageUrls = [
                  'https://images.unsplash.com/photo-1447933601403-0c6688de566e?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1061',
                  'https://images.unsplash.com/photo-1607532941433-304659e8198a?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1078',
                  'https://images.unsplash.com/photo-1487383298905-ee8a6b373ff9?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8c25vd3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
                ];

                return Image.network(
                  imageUrls[index % imageUrls.length],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: Text('이미지')),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
