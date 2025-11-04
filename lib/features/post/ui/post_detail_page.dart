import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("포스트 상세")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "←",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("친구1"),
                  Spacer(),
                  Text(
                    "2025.11.04",
                    style: TextStyle(fontSize: 10, color: Color(0xFF515151)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 350,
                width: double.infinity,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("❤️ "),
                  Text("좋아요 ", style: TextStyle(fontSize: 13)),
                  Text("24", style: TextStyle(fontSize: 13)),
                  Spacer(),
                  Text("신고하기", style: TextStyle(fontSize: 13)),
                ],
              ),
              Divider(),
              Row(
                children: [
                  Text("주제:"),
                  Text(" 겨울풍경", style: TextStyle(color: Color(0xFF95B7DB))),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 120,
                color: Color(0xFFFCFCF0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("댓글"),
                        ),
                        Text(
                          " 0",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(child: Text("첫 댓글을 남겨보세요!")),
                  ],
                ),
              ),
              Spacer(),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 30,
                    width: 430,
                    color: Colors.white,
                    child: Text(
                      "댓글을 입력하세요.. ",
                      style: TextStyle(color: Color(0xFFD9D9D9)),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Container(
                    alignment: Alignment.center,

                    width: 40,
                    color: Color(0xFF95B7DB),
                    child: Text(
                      "⌲",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
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
