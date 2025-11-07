import 'package:flutter/material.dart';
import 'package:opicproject/features/friend/component/friend_info_row.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("친구목록 페이지")),
      body: SafeArea(child: Column(children: [FriendInfoRow(userId: 1)])),
    );
  }
}
