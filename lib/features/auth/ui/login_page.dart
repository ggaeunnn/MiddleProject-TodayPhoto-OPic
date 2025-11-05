import 'package:flutter/material.dart';

class OpicLoginPage extends StatelessWidget {
  const OpicLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFFCFCF0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 120,
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image.asset(
                        'assets/images/logo_square_skyblue.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      "오늘의 한 장",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("로그인해서 시작하세요"),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: SigninGoogle(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SigninGoogle extends StatelessWidget {
  const SigninGoogle({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
      ),
      onPressed: () {
        // 구글 로그인
      },
      child: Image.asset('assets/images/sign_in_google.png'),
    );
  }
}
