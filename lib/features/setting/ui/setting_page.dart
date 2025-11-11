import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/user_model.dart';
import 'package:opicproject/features/setting/component/edit_nickname_pop_up.dart';
import 'package:url_launcher/url_launcher.dart';

final List<UserInfo> dummyUsers = UserInfo.getDummyUsers();
final loginUser = dummyUsers[0];

class SettingScreen extends StatelessWidget {
  final int userId;
  const SettingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: _SettingScreen());
  }
}

class _SettingScreen extends StatefulWidget {
  const _SettingScreen({super.key});

  @override
  State<_SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<_SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: AppColors.opicBackground,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.opicWhite,
                  border: Border(
                    top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
                  ),
                ),
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
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
                          color: AppColors.opicBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.opicWhite,
                  border: Border(
                    top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
                    bottom: BorderSide(
                      color: AppColors.opicSoftBlue,
                      width: 0.5,
                    ),
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
                        color: AppColors.opicSoftBlue,
                      ),
                      Text(
                        AuthManager.shared.userInfo?.nickname ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.opicBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: AppColors.opicBackground,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: AppColors.opicWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.opicSoftBlue,
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
                                context.push('/setting_alarm_page');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.opicSoftBlue,
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
                                            color: AppColors.opicSoftBlue,
                                          ),
                                          Text(
                                            "알림설정",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColors.opicBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.opicBlack,
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
                                      color: AppColors.opicSoftBlue,
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
                                            color: AppColors.opicSoftBlue,
                                          ),
                                          Text(
                                            "문의사항",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColors.opicBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.opicBlack,
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
                                      color: AppColors.opicSoftBlue,
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
                                            color: AppColors.opicSoftBlue,
                                          ),
                                          Text(
                                            "닉네임 수정",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColors.opicBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.opicBlack,
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
                                      context.pop();
                                    },
                                    onCancel: () {
                                      context.pop();
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
                                          color: AppColors.opicRed,
                                        ),
                                        Text(
                                          "회원탈퇴",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.opicRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.opicBlack,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Text(
                        "오늘 한 장",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.opicLightBlack,
                        ),
                      ),
                      Text(
                        "VER 1.0.0",
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.opicLightBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
