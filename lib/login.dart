import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_sns/colors.dart';
import 'package:login_sns/route_auth_sns_sign_up.dart';
import 'package:login_sns/route_main.dart';
import 'package:login_sns/route_splash.dart';
import 'package:login_sns/text_style.dart';
import 'package:login_sns/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'gaps.dart';
import 'keys.dart';

class RouteAuthLogin extends StatefulWidget {
  const RouteAuthLogin({super.key});

  @override
  State<RouteAuthLogin> createState() => _RouteLoginState();
}

class _RouteLoginState extends State<RouteAuthLogin> {
  final TextEditingController tecEmail = TextEditingController();
  final TextEditingController tecPw = TextEditingController();
  final ValueNotifier<bool> vnObscureTextNotifier = ValueNotifier<bool>(true);

  // final ValueNotifier<bool> vnIsCheck = ValueNotifier(false);
  bool isPasswordOverSix = false;

  @override
  void dispose() {
    tecEmail.dispose();
    tecPw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                children: [

                  Gaps.v30,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final UserCredential? userCredential = await Utils.onGoogleTap();
                          if (userCredential != null) {
                            final uid = userCredential.user!.uid;
                            final userDs =
                            await FirebaseFirestore.instance.collection(keyUser).where(keyEmail, isEqualTo: userCredential.user!.email).get();
                            // 회원가입이 안됨
                            if (userDs.docs.isEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RouteAuthSnsSignUp(
                  /*                  uid: uid,
                                    email: userCredential.user!.email!,
                                    loginType: LoginType.google,*/
                                  ),
                                ),
                              );
                            }

                            // 회원가입이 되어있음
                            else {
                              final pref = await SharedPreferences.getInstance();
                              pref.setString(keyUid, uid);
                              Navigator.of(context)
                                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                            }
                          }
                        },
                        child: Text(
                          '구글로그인'
                        ),
                      ),
                 Gaps.h20,
                      GestureDetector(
                        onTap: () async {
                          final String? uid = await Utils.onKakaoTap();
                          if (uid != null) {
                            final userDs = await FirebaseFirestore.instance.collection(keyUser).where(keyUid, isEqualTo: uid).get();
                            // 회원가입이 안됨
                            if (userDs.docs.isEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RouteMain(
                                  ),
                                ),
                              );
                            }

                            // 회원가입이 되어있음
                            else {
                              final pref = await SharedPreferences.getInstance();
                              pref.setString(keyUid, uid);
                              Navigator.of(context)
                                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                            }
                          }
                        },
                        child: Text('카카오톡'),
                      ),


                      /*
                      if (Platform.isIOS)
                        Row(
                          children: [
                            Gaps.h20,
                            GestureDetector(
                              onTap: () async {
                                final UserCredential? userCredential = await Utils.onAppleTap();
                                if (userCredential != null) {
                                  final uid = userCredential.user!.uid;
                                  final userDs = await FirebaseFirestore.instance
                                      .collection(keyUser)
                                      .where(keyEmail, isEqualTo: userCredential.user!.email)
                                      .get();
                                  // 회원가입이 안됨
                                  if (userDs.docs.isEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RouteAuthSnsSignUp(
                                          uid: uid,
                                          email: userCredential.user!.email!,
                                          loginType: LoginType.apple,
                                        ),
                                      ),
                                    );
                                  }

                                  // 회원가입이 되어있음
                                  else {
                                    final pref = await SharedPreferences.getInstance();
                                    pref.setString(keyUid, uid);
                                    Navigator.of(context)
                                        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                                  }
                                }
                              },
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Image.asset(
                                  'assets/images/apple.png',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ],
                        )*/
                    ],
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

/*  Future<void> loginCheck(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (tecEmail.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: 'Enter Email',
        ),
      );
      return;
    }

    if (tecPw.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: 'Enter password',
        ),
      );
      return;
    }

    final targetUserDs = await FirebaseFirestore.instance.collection(keyUser).where(keyEmail, isEqualTo: tecEmail.text).get();
    if (targetUserDs.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: 'This user is not exist',
        ),
      );
      return;
    }
    final targetUser = ModelUser.fromJson(targetUserDs.docs.first.data());

    if (targetUser.pw != tecPw.text) {
      showDialog(
        context: context,
        builder: (context) => const DialogConfirm(
          desc: 'Password is not matched',
        ),
      );
      return;
    }

    final pref = await SharedPreferences.getInstance();
    pref.setString(keyUid, targetUser.uid);

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
  }*/
}

class _WidgetText extends StatelessWidget {
  final String title;
  final void Function()? onTap;

  const _WidgetText({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.transparent,
          child: Text(
            title,
            style: const TS.s13w400(colorGray600),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
