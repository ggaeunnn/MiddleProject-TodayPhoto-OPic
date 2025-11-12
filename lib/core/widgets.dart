import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/app_colors.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/page_model.dart';
import 'package:opicproject/features/feed/ui/feed.dart';
import 'package:opicproject/features/friend/ui/friend_page.dart';
import 'package:opicproject/features/home/home.dart';
import 'package:opicproject/features/setting/ui/setting_page.dart';
import 'package:provider/provider.dart';

class OpicAppbar extends StatelessWidget implements PreferredSizeWidget {
  const OpicAppbar({super.key});

  @override
  Widget build(BuildContext context) {
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
              Container(
                child: IconButton(
                  onPressed: () {
                    context.push('/alarm_list_page');
                  },
                  icon: Icon(
                    Icons.notifications_none,
                    color: AppColors.opicSoftBlue,
                  ),
                ),
              ),
              Container(
                child: IconButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  icon: Icon(Icons.exit_to_app, color: AppColors.opicSoftBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
}

/// 하단네비게이션

class OpicBottomNav extends StatefulWidget {
  const OpicBottomNav({super.key});

  @override
  State<OpicBottomNav> createState() => _OpicBottomNavState();
}

class _OpicBottomNavState extends State<OpicBottomNav> {
  @override
  Widget build(BuildContext context) {
    final PageViewmodel = context.watch<PageCountViewmodel>();
    final pageViewmodelRead = context.read<PageCountViewmodel>();
    final currentpage = PageViewmodel.currentPage;
    return BottomNavigationBar(
      onTap: (index) {
        pageViewmodelRead.onPageChanged(index);
      },
      currentIndex: currentpage,
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

class OpicPageView extends StatefulWidget {
  const OpicPageView({super.key});

  @override
  State<OpicPageView> createState() => _OpicPageViewState();
}

class _OpicPageViewState extends State<OpicPageView> {
  @override
  Widget build(BuildContext context) {
    final PageViewmodel = context.watch<PageCountViewmodel>();
    final PageViewmodelRead = context.read<PageCountViewmodel>();
    final currentpage = PageViewmodel.currentPage;
    final PageController pageController = context
        .watch<PageCountViewmodel>()
        .pageController;
    final loginUserId = AuthManager.shared.userInfo?.id ?? 0;
    return PageView(
      onPageChanged: (index) {
        if (index > currentpage) {
          PageViewmodelRead.increment();
        }
        if (index < currentpage) {
          PageViewmodelRead.decrement();
        }
      },
      controller: pageController,
      children: [
        HomeScreen(),
        FriendScreen(),
        FeedScreen(userId: loginUserId),
        SettingScreen(),
      ],
    );
  }
}
