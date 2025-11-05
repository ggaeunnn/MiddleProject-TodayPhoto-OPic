import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int commentCount = 0;
  int likeCount = 0;
  bool buttonLike = true;
  bool buttonReport = true;
  String loginUserName = "친구1";
  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  String todayTopic = "겨울풍경";

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
              IconButton(
                onPressed: () {
                  // 게시물 목록으로 가기
                },
                icon: Icon(Icons.keyboard_backspace),
              ),
              // SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("${loginUserName}"),
                          Spacer(),
                          Text(
                            "${formattedDate}",
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF515151),
                            ),
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
                          IconButton(
                            icon: Icon(
                              (buttonLike)
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                            ),
                            iconSize: 20,
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                buttonLike = !buttonLike;
                              });
                            },
                          ),
                          Text("좋아요 ", style: TextStyle(fontSize: 13)),
                          Text("${likeCount}", style: TextStyle(fontSize: 13)),
                          Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              myDialog(context);
                            },
                            icon: Icon(Icons.outlined_flag),
                            label: Text('신고하기'),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: [
                          Text("주제:"),
                          TextButton(
                            onPressed: () {
                              //주제 클릭 시 게시물 목록으로 이동
                            },
                            child: Text(
                              "${todayTopic}",
                              style: TextStyle(color: Color(0xFF95B7DB)),
                            ),
                          ),
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
                                  " ${commentCount}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Center(child: Text("첫 댓글을 남겨보세요!")),
                          ],
                        ),
                      ),
                      // Spacer(),
                      Divider(),
                    ],
                  ),
                ),
              ),

              //댓글 입력 창
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 35,
                    width: 430,
                    color: Colors.white,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "댓글을 입력하세요..",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),

                    // Text(
                    //   "댓글을 입력하세요.. ",
                    //   style: TextStyle(color: Color(0xFFD9D9D9)),
                    // ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Container(
                    alignment: Alignment.center,
                    width: 35,
                    height: 35,
                    color: Color(0xFF95B7DB),
                    child: IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 20,
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          //댓글이 등록되기
                        });
                      },
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

void myDialog(context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          height: 300,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("신고사유를 적어주세요"),
              SizedBox(height: 20),
              Container(
                color: Colors.white,
                height: 150,
                width: 200,
                child: Text("신고사유적기"),
              ),
              // IconButton(
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              //   icon: const Icon(Icons.close),
              // ),
            ],
          ),
        ),
      );
    },
  );
}
