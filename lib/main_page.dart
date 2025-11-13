import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/widgets.dart';

class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    final isLoggedIn = AuthManager.shared.userInfo != null;
    if (index > 0 && !isLoggedIn) {
      context.push('/login');
      return;
    }

    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OpicAppbar(),
        body: navigationShell,
        bottomNavigationBar: OpicBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
        ),
      ),
    );
  }
}
