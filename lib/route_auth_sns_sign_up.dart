import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteAuthSnsSignUp extends StatefulWidget {

  @override
  State<RouteAuthSnsSignUp> createState() => _RouteAuthSnsSignUpState();
}

class _RouteAuthSnsSignUpState extends State<RouteAuthSnsSignUp> {
  final TextEditingController tecNickName = TextEditingController();
  final ValueNotifier<bool> vnIsComplete = ValueNotifier(false);
  final fn = FocusNode();

  @override
  void dispose() {
    tecNickName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Text('로그인가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
