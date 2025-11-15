import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/widgets.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime? lastBackPressed;

  void _onTap(BuildContext context, int index, bool isLoggedIn) {
    if (index > 0 && !isLoggedIn) {
      context.push('/login');
      return;
    }

    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (context, authManager, child) {
        final isLoggedIn = authManager.userInfo != null;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              final now = DateTime.now();

              if (widget.navigationShell.currentIndex != 0) {
                widget.navigationShell.goBranch(0);
                return;
              }

              if (lastBackPressed == null ||
                  now.difference(lastBackPressed!) > Duration(seconds: 2)) {
                lastBackPressed = now;
                Fluttertoast.showToast(
                  msg: '뒤로가기 버튼을 한 번 더 누르면 앱이 종료 됩니다',
                  backgroundColor: AppColors.opicBlue,
                  textColor: AppColors.opicWhite,
                );
              } else {
                SystemNavigator.pop();
              }
            }
          },
          child: SafeArea(
            child: Scaffold(
              appBar: OpicAppbar(),
              body: widget.navigationShell,
              bottomNavigationBar: OpicBottomNav(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (index) => _onTap(context, index, isLoggedIn),
              ),
            ),
          ),
        );
      },
    );
  }
}
