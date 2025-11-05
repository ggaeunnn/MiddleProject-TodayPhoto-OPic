import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpicAppbar extends StatelessWidget implements PreferredSizeWidget {
  const OpicAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                    onPressed: () {},
                    icon: Icon(Icons.exit_to_app),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
}

class OpicBottomNav extends StatelessWidget {
  const OpicBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
