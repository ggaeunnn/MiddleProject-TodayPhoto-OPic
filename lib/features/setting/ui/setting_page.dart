import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/features/setting/component/edit_nickname_pop_up.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/user_model.dart';
import '../../../core/widgets.dart';

final List<User> dummyUsers = User.getDummyUsers();
final loginUser = dummyUsers[0];

class SettingPage extends StatelessWidget {
  final int userId;
  const SettingPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: _SettingPage());
  }
}

class _SettingPage extends StatefulWidget {
  const _SettingPage({super.key});

  @override
  State<_SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<_SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: OpicAppbar(),
      bottomNavigationBar: OpicBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xfffafafa),
                border: Border(
                  top: BorderSide(color: Color(0xff95b7db), width: 0.5),
                ),
              ),
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  spacing: 10,
                  children: [
                    /// 하단 탭으로 이동하기 때문에 뒤로가기 버튼 제거함
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.arrow_back_rounded,
                    //     color: Color(0xff515151),
                    //   ),
                    //   onPressed: () {},
                    //   splashColor: Colors.transparent,
                    //   highlightColor: Colors.transparent,
                    //   hoverColor: Colors.transparent,
                    //   focusColor: Colors.transparent,
                    // ),
                    Text(
                      "설정",
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
            Container(
              decoration: BoxDecoration(
                color: Color(0xfffafafa),
                border: Border(
                  top: BorderSide(color: Color(0xff95b7db), width: 0.5),
                  bottom: BorderSide(color: Color(0xff95b7db), width: 0.5),
                ),
              ),
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 70,
                      color: Color(0xff95b7db),
                    ),
                    Text(
                      loginUser.nickname,
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
                          GestureDetector(
                            onTap: () {
                              context.go('/setting_alarm_page');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xff95b7db),
                                    width: 0.3,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      children: [
                                        Icon(
                                          Icons.notifications,
                                          color: Color(0xff95b7db),
                                        ),
                                        Text(
                                          "알림설정",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xff515151),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xff515151),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',

                                /// 문의사항 접수 이메일 주소 적어야 함!
                                path: 'report@email.com',
                              );
                              if (await canLaunchUrl(emailUri)) {
                                await launchUrl(
                                  emailUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xff95b7db),
                                    width: 0.3,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      children: [
                                        Icon(
                                          Icons.report_problem_rounded,
                                          color: Color(0xff95b7db),
                                        ),
                                        Text(
                                          "문의사항",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xff515151),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xff515151),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.6),
                                builder: (context) => EditNicknamePopUp(
                                  currentNickname: loginUser.nickname,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xff95b7db),
                                    width: 0.3,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      children: [
                                        Icon(
                                          Icons.person_rounded,
                                          color: Color(0xff95b7db),
                                        ),
                                        Text(
                                          "닉네임 수정",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xff515151),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xff515151),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.6),
                                builder: (context) => YesOrClosePopUp(
                                  title: "탈퇴하시겠습니까?",
                                  text: "회원 탈퇴 시 삭제되는 데이터는 복구할 수 없습니다",
                                  confirmText: "탈퇴하기",
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                  },
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        Icons.person_off_rounded,
                                        color: Color(0xff95b7db),
                                      ),
                                      Text(
                                        "회원탈퇴",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xff515151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xff515151),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Text(
                      "오늘 한 장",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xffd9d9d9),
                      ),
                    ),
                    Text(
                      "VER 1.0.0",
                      style: TextStyle(fontSize: 9, color: Color(0xffd9d9d9)),
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
