import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/widgets.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index, bool isLoggedIn) {
    if (index > 0 && !isLoggedIn) {
      context.push('/login');
      return;
    }

    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (context, authManager, child) {
        final isLoggedIn = authManager.userInfo != null;
        return SafeArea(
          child: Scaffold(
            appBar: OpicAppbar(),
            body: navigationShell,
            bottomNavigationBar: OpicBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => _onTap(context, index, isLoggedIn),
            ),
          ),
        );
      },
    );
  }
}
