import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/features/post/ui/post_delete_popup.dart';
import 'package:opicproject/features/post/ui/post_edit_popup.dart';
import 'package:opicproject/features/post_report/ui/post_report_page.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // int commentCount = 0;
  int likeCount = 0;
  bool buttonLike = true;
  bool buttonReport = true;
  String loginUserName = "친구1";
  String postWriter = "친구1";
  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  late String commentDate = DateFormat('yyyy-MM-dd hh-mm').format(now);
  String todayTopic = "겨울풍경";
  List<String> commentList = [];
  final _commentListController = TextEditingController();

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
                  context.go('/home');
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
                          Text("${postWriter}"),
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

                      //사진
                      Image.network(
                        'https://images.unsplash.com/photo-1455156218388-5e61b526818b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFQSVCMiVBOCVFQyU5QSVCOHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500',
                        width: double.infinity,
                        height: 350,
                        fit: BoxFit.fill,
                      ),
                      // Container(
                      //   height: 350,
                      //   width: double.infinity,
                      //   color: Colors.grey,
                      // ),
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
                                if (buttonLike) {
                                  likeCount -= 1;
                                } else {
                                  likeCount += 1;
                                }
                              });
                            },
                          ),
                          Text("좋아요 ", style: TextStyle(fontSize: 13)),
                          Text("${likeCount}", style: TextStyle(fontSize: 13)),
                          Spacer(),

                          // 내 게시물이라면 수정하기/삭제하기
                          (loginUserName == postWriter)
                              ? Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF95B7DB),
                                        fixedSize: Size(105, 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.black
                                              .withOpacity(0.6),
                                          builder: (context) => EditPopup(),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      label: Text(
                                        "수정하기",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(5)),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFFC8C8),
                                        fixedSize: Size(105, 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.black
                                              .withOpacity(0.6),
                                          builder: (context) => DeletePopup(
                                            // currentNickname: loginUser.nickname,
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Color(0xFFFF826F),
                                        size: 12,
                                      ),
                                      label: Text(
                                        "삭제하기",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              :
                                // 다른 사람 게시물이라면 신고하기
                                TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withOpacity(
                                        0.6,
                                      ),
                                      builder: (context) => PostReportScreen(
                                        // currentNickname: loginUser.nickname,
                                      ),
                                    );
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
                              context.go('/home');
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
                        // height: 120,
                        color: Color(0xFFFCFCF0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text("댓글"),
                                ),
                                Text(
                                  " ${commentList.length}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // SizedBox(height: 20),
                            Center(
                              child: (commentList.isEmpty)
                                  ? Text("첫 댓글을 남겨보세요!")
                                  : ListView.builder(
                                      itemCount: commentList.length,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            return Container(
                                              padding: EdgeInsets.only(
                                                left: 10,
                                              ),
                                              width: 100,
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          context.go(
                                                            '/friend_feed',
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.person,
                                                        ),
                                                      ),
                                                      Text("${loginUserName}"),
                                                      Spacer(),
                                                      Text(
                                                        "${commentDate}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Color(
                                                            0xFF515151,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              right: 8,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                      left: 20,
                                                    ),
                                                    width: double.infinity,
                                                    child: Text(
                                                      "${commentList[index]}",
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  // Padding(
                                                  //   padding: EdgeInsets.only(
                                                  //     bottom: 5,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            );
                                          },
                                    ),
                            ),
                            SizedBox(height: 20),
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
                    width: 350,
                    color: Colors.white,
                    child: TextField(
                      //이거 추가함
                      controller: _commentListController,
                      decoration: InputDecoration(
                        hintText: "댓글을 입력하세요..",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
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
                          commentList.add("${_commentListController.text}");
                          _commentListController.clear();
                          showToast("댓글작성이 완료되었습니다.");
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

  @override
  void dispose() {
    _commentListController.dispose();
    super.dispose();
  }
}

void showToast(String content) {
  Fluttertoast.showToast(
    msg: content,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: AppColors.opicLightBlack,
    fontSize: 12,
    textColor: AppColors.opicBlack,
    toastLength: Toast.LENGTH_SHORT,
  );
}
