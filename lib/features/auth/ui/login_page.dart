import 'package:flutter/material.dart';
import 'package:opicproject/core/widgets.dart';

class OpicLoginPage extends StatelessWidget {
  const OpicLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: OpicAppbar(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFFCFCF0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/logo_square_skyblue.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Text("오늘의 한장"),
                Text("로그인해서 시작하세요"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
