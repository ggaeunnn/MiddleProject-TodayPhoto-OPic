import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opicproject/core/models/page_model.dart';
import 'package:opicproject/features/feed/ui/feed.dart';
import 'package:opicproject/features/friend/ui/friend_page.dart';
import 'package:opicproject/features/home/home.dart';
import 'package:provider/provider.dart';

class OpicAppbar extends StatelessWidget implements PreferredSizeWidget {
  const OpicAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  icon: Icon(Icons.notifications_none),
                ),
              ),
              Container(
                child: IconButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  icon: Icon(Icons.exit_to_app),
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
        if (index == 3) {
          context.push('/setting_page');
        }
      },
      currentIndex: currentpage,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: IconThemeData(color: Color(0xFF95B7DB)),
      unselectedIconTheme: IconThemeData(color: Colors.grey),
      selectedItemColor: Color(0xFF95B7DB),
      unselectedItemColor: Colors.grey,
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
      children: [HomeScreen(), FriendScreen(), MyFeedScreen()],
    );
  }
}
