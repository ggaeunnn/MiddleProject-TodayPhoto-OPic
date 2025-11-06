import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/features/alarm/component/alarm_row_comment.dart';
import 'package:opicproject/features/alarm/component/alarm_row_friend_accept.dart';
import 'package:opicproject/features/alarm/component/alarm_row_friend_request.dart';
import 'package:opicproject/features/alarm/component/alarm_row_like.dart';
import 'package:opicproject/features/alarm/component/alarm_row_topic.dart';

class AlarmListScreen extends StatelessWidget {
  final int userId;
  const AlarmListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: _AlarmListScreen());
  }
}

class _AlarmListScreen extends StatefulWidget {
  const _AlarmListScreen({super.key});

  @override
  State<_AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<_AlarmListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xfffafafa),
                border: Border(
                  bottom: BorderSide(color: Color(0xff95b7db), width: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xff515151),
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                    Text(
                      "알림",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xff515151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Color(0xfffcfcf0),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),

                  /// ListView 처리 필요
                  child: Column(
                    children: [
                      AlarmRowLike(),
                      AlarmRowTopic(),
                      AlarmRowComment(),
                      AlarmRowFriendRequest(),
                      AlarmRowFriendAccept(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
