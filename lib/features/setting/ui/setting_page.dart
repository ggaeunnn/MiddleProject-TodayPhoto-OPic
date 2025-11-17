import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/component/yes_or_close_pop_up.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/setting/component/edit_nickname_pop_up.dart';
import 'package:opicproject/features/setting/viewmodel/setting_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.opicBackground,
      body: SafeArea(
        child: Consumer<SettingViewModel>(
          builder: (context, viewModel, child) {
            final authManager = context.read<AuthManager>();
            final loginUserId = authManager.userInfo?.id ?? 0;
            final nickname = _getNickname(viewModel, authManager);

            return Column(
              children: [
                _buildProfileSection(nickname),
                Expanded(
                  child: _buildSettingMenu(context, loginUserId, nickname),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getNickname(SettingViewModel viewModel, AuthManager authManager) {
    return viewModel.loginUser?.nickname ??
        authManager.userInfo?.nickname ??
        "닉네임을 정해주세요";
  }

  // 프로필
  Widget _buildProfileSection(String nickname) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.opicWhite,
        border: Border(
          top: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
          bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.5),
        ),
      ),
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
              nickname,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.opicBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingMenu(
    BuildContext context,
    int loginUserId,
    String nickname,
  ) {
    return Container(
      color: AppColors.opicBackground,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: AppColors.opicWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.opicSoftBlue, width: 0.7),
            ),
            child: Column(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 알림 설정
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications,
                  iconColor: AppColors.opicSoftBlue,
                  title: "푸시 알림 설정",
                  titleColor: AppColors.opicBlack,
                  onTap: () => context.push('/setting_alarm_page'),
                  showDivider: true,
                ),
                // 문의사항
                _buildMenuItem(
                  context: context,
                  icon: Icons.report_problem_rounded,
                  iconColor: AppColors.opicSoftBlue,
                  title: "문의사항",
                  titleColor: AppColors.opicBlack,
                  onTap: () => _sendEmail(),
                  showDivider: true,
                ),
                // 닉네임 수정
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_rounded,
                  iconColor: AppColors.opicSoftBlue,
                  title: "닉네임 변경",
                  titleColor: AppColors.opicBlack,
                  onTap: () =>
                      _showEditNicknamePopUp(context, loginUserId, nickname),
                  showDivider: true,
                ),
                // 회원탈퇴
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_rounded,
                  iconColor: AppColors.opicRed,
                  title: "회원탈퇴",
                  titleColor: AppColors.opicRed,
                  onTap: () => _showExitPopUp(context),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(color: AppColors.opicSoftBlue, width: 0.3),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                children: [
                  Icon(icon, color: iconColor),
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, color: titleColor),
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
    );
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'report@email.com');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showEditNicknamePopUp(
    BuildContext context,
    int loginUserId,
    String nickname,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => EditNicknamePopUp(
        loginUserId: loginUserId,
        loginUserNickname: nickname,
      ),
    );
  }

  void _showExitPopUp(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => YesOrClosePopUp(
        title: "탈퇴하시겠습니까?",
        text: "회원 탈퇴 시 삭제되는 데이터는 복구할 수 없습니다",
        confirmText: "탈퇴하기",
        onConfirm: () {
          AuthManager.shared.withdraw();
          context.pop();
          context.go("/home");
        },
        onCancel: () {
          context.pop();
        },
      ),
    );
  }
}
