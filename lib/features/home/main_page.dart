import 'package:flutter/material.dart';
import 'package:opicproject/core/widgets.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OpicAppbar(),
        body: OpicPageView(),
        bottomNavigationBar: OpicBottomNav(),
      ),
    );
  }
}
