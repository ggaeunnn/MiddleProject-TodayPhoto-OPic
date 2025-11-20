import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/features/alarm/viewmodel/alarm_view_model.dart';
import 'package:provider/provider.dart';

// 상단 앱바
class OpicAppbar extends StatefulWidget implements PreferredSizeWidget {
  const OpicAppbar({super.key});

  @override
  State<OpicAppbar> createState() => _OpicAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(50);
}

class _OpicAppbarState extends State<OpicAppbar> {
  @override
  void initState() {
    super.initState();
    // 앱바가 생성될 때 알림 리스트 로드 및 로그인 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authManager = context.read<AuthManager>();
      if (authManager.userInfo != null) {
        context.read<AlarmViewModel>().fetchAlarms(
          1,
          authManager.userInfo?.id ?? 0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthManager, AlarmViewModel>(
      builder: (context, authManager, alarmViewModel, child) {
        final isLoggedIn = authManager.userInfo != null;

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: Image.asset('assets/images/logo_long_skyblue.png'),
              ),
              Row(
                children: [
                  if (isLoggedIn)
                    Stack(
                      children: [
                        // 알림 리스트 화면 열기
                        IconButton(
                          onPressed: () {
                            context.push('/alarm_list_page');
                          },
                          icon: Icon(
                            Icons.notifications_none,
                            color: AppColors.opicSoftBlue,
                          ),
                        ),
                        if (alarmViewModel.hasUnreadAlarm)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.opicRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  // 로그인/로그아웃 버튼 -> 로그인 여부에 따라 아이콘 다름
                  isLoggedIn
                      ? Container(
                          child: IconButton(
                            onPressed: () {
                              context.push('/login');
                            },
                            icon: Icon(
                              Icons.exit_to_app_rounded,
                              color: AppColors.opicSoftBlue,
                            ),
                          ),
                        )
                      : Container(
                          child: IconButton(
                            onPressed: () {
                              context.push('/login');
                            },
                            icon: Icon(
                              Icons.login_rounded,
                              color: AppColors.opicSoftBlue,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// 하단네비게이션 바
class OpicBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const OpicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTap,
      currentIndex: currentIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: IconThemeData(color: AppColors.opicSoftBlue),
      unselectedIconTheme: IconThemeData(color: AppColors.opicCoolGrey),
      selectedItemColor: AppColors.opicSoftBlue,
      unselectedItemColor: AppColors.opicCoolGrey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구'),
        BottomNavigationBarItem(icon: Icon(Icons.image), label: '내 피드'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}
