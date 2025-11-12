import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/setting/component/edit_nickname_pop_up.dart';
import 'package:opicproject/features/setting/data/setting_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(child: _SettingScreen());
  }
}

class _SettingScreen extends StatefulWidget {
  const _SettingScreen();

  @override
  State<_SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<_SettingScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginUserId = AuthManager.shared.userInfo?.id;
      if (loginUserId != null) {
        context.read<SettingViewModel>().fetchUserInfo(loginUserId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginUserId = AuthManager.shared.userInfo?.id ?? 0;

    return Scaffold(
      backgroundColor: AppColors.opicBackground,
      body: SafeArea(
        child: Consumer<SettingViewModel>(
          builder: (context, viewModel, child) {
            // ViewModel에서 직접 닉네임 가져오기
            final displayNickname =
                viewModel.loginUser?.nickname ??
                AuthManager.shared.userInfo?.nickname ??
                "알 수 없음";

            return Column(
              children: [
                // 헤더
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.opicWhite,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.opicSoftBlue,
                        width: 0.5,
                      ),
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

                // 프로필 섹션
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.opicWhite,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.opicSoftBlue,
                        width: 0.5,
                      ),
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
                          displayNickname,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.opicBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 설정 메뉴
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
                              // 알림 설정
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
                                              "푸시 알림 설정",
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

                              // 문의사항
                              GestureDetector(
                                onTap: () async {
                                  final Uri emailUri = Uri(
                                    scheme: 'mailto',
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

                              // 닉네임 수정
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black.withOpacity(0.6),
                                    builder: (context) => EditNicknamePopUp(
                                      loginUserId: loginUserId,
                                      loginUserNickname: displayNickname,
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

                              // 회원탈퇴
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
