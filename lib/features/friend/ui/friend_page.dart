import 'package:flutter/material.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(title: const Text("친구목록 페이지")),
        body: SafeArea(child: Column(children: [Text("친구친구")])),
      ),
    );
  }
}
