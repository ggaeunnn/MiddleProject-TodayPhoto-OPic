import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              color: Color(0xfffafafa),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10.0,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.arrow_back_rounded, color: Color(0xff515151)),
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
                      "닉네임자리",
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
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Icon(
                                        Icons.add_alert_rounded,
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
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
