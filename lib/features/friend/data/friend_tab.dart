import 'package:flutter/material.dart';

enum FriendTab {
  friends(0, '친구', null),
  requests(1, '요청', Icons.mail_outline_rounded),
  blocked(2, '차단', Icons.block_rounded);

  final int number;
  final String label;
  final IconData? icon;

  const FriendTab(this.number, this.label, this.icon);
}
