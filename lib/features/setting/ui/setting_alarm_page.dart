import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/features/setting/component/switch_row.dart';

class SettingAlarmPage extends StatefulWidget {
  const SettingAlarmPage({super.key});

  @override
  State<SettingAlarmPage> createState() => _SettingAlarmPageState();
}

class _SettingAlarmPageState extends State<SettingAlarmPage> {
  bool allAlarm = true;
  bool newTopic = true;
  bool likePost = true;
  bool newComment = true;
  bool newRequest = true;
  bool newFriend = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xfffafafa),
                border: Border(
                  bottom: BorderSide(color: Color(0xff95b7db), width: 0.5),
                ),
              ),
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  spacing: 10,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xff515151),
                      ),
                      onPressed: () {
                        context.go('/setting_page');
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                    Text(
                      "알림 설정",
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
                color: Color(0xfffcfcf0),
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xff95b7db),
                          width: 0.7,
                        ),
                      ),
                      child: Column(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xff95b7db),
                                  width: 0.3,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 5.0,
                              ),
                              child: SwitchRow(
                                title: '전체 알람',
                                value: allAlarm,
                                onChanged: (v) => setState(() {
                                  allAlarm = v;
                                  if (!v) {
                                    newTopic = false;
                                    likePost = false;
                                    newComment = false;
                                    newRequest = false;
                                    newFriend = false;
                                  }
                                }),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xff95b7db),
                                  width: 0.3,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 5.0,
                              ),
                              child: SwitchRow(
                                title: '새로운 주제',
                                value: newTopic,
                                onChanged: (v) => setState(() => newTopic = v),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xff95b7db),
                                  width: 0.3,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 5.0,
                              ),
                              child: SwitchRow(
                                title: '좋아요',
                                value: likePost,
                                onChanged: (v) => setState(() => likePost = v),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xff95b7db),
                                  width: 0.3,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 5.0,
                              ),
                              child: SwitchRow(
                                title: '댓글',
                                value: newComment,
                                onChanged: (v) =>
                                    setState(() => newComment = v),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xff95b7db),
                                  width: 0.3,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 5.0,
                              ),
                              child: SwitchRow(
                                title: '친구 요청 도착',
                                value: newRequest,
                                onChanged: (v) =>
                                    setState(() => newRequest = v),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xff95b7db),
                                  width: 0.3,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 5.0,
                              ),
                              child: SwitchRow(
                                title: '친구 요청 수락',
                                value: newFriend,
                                onChanged: (v) => setState(() => newFriend = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
