import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:login_sns/colors.dart';
import 'package:login_sns/route_auth_sns_sign_up.dart';
import 'package:login_sns/route_main.dart';
import 'package:login_sns/route_splash.dart';
import 'package:login_sns/text_style.dart';
import 'package:login_sns/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
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
                            final userDs = await FirebaseFirestore.instance
                                .collection(keyUser)
                                .where(keyEmail, isEqualTo: userCredential.user!.email)
                                .get();
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
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                            }
                          }
                        },
                        child: Text('구글로그인'),
                      ),
                      Gaps.h20,
                      GestureDetector(
                        onTap: () async {
                          _loginWithKakao();
            /*              final String? uid = await Utils.onKakaoTap();
                          if (uid != null) {
                            final userDs = await FirebaseFirestore.instance
                                .collection(keyUser)
                                .where(keyUid, isEqualTo: uid)
                                .get();
                            // 회원가입이 안됨
                            if (userDs.docs.isEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RouteMain(),
                                ),
                              );
                            }

                            // 회원가입이 되어있음
                            else {
                              final pref = await SharedPreferences.getInstance();
                              pref.setString(keyUid, uid);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const RouteSplash()), (route) => false);
                            }
                          }*/
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
  void _loginWithKakao() async {

    // [1] 카카오톡이 설치되어있는지 확인
    bool isInstalled;
    try {
      isInstalled = await isKakaoTalkInstalled();
    } catch (e, s) {
      isInstalled = false;
      Utils.log.f('카카오톡이 설치되지 않음\n$e\n$s');
    }

    // [2] 토큰 받기
    // 카카오톡이 설치되어 있으면 token 받고, 설치되어 있지 않으면 계정로그인으로 token 받기
    OAuthToken token;
    if (isInstalled) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        Utils.log.i('카카오톡으로 로그인 성공');
      } catch (e, s) {
        Utils.log.f('카카오톡으로 로그인 실패\n$e\n$s');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (e is PlatformException && e.code == 'CANCELED') {
          Utils.log.f('로그인 취소\ne is PlatformException && e.code == "CANCELED"');
        }
        return;
      }
    }
    // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
    else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
      } catch (e, s) {
        Utils.log.f('카카오 계정으로 로그인 실패\n$e\n$s');
        return;
      }
    }
    dynamic kakaoProfile;

    // [3] 카카오 유저정보 가져오기
    try {
      final url = Uri.https('kapi.kakao.com', '/v2/user/me');
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'},
      );

      kakaoProfile = json.decode(response.body);
      Utils.log.d('프로필 정보 : ${kakaoProfile.toString()}');
    } catch (e, s) {
      Utils.log.f('카카오 유저정보 가져오기 실패\n$e\n$s');
    }

    // [4] token을 이용하여 파이어베이스에 인증
    try {
      Utils.log.d(
        "카카오 인증 결과\n"
            "socialKey: ${kakaoProfile[keyId]}\n"
            "name: ${kakaoProfile['properties'][keyNickname]}\n"
            "email: ${kakaoProfile['properties'][keyEmail]}",
      );

      final String socialKey = kakaoProfile[keyId].toString();

   /*   final ModelSnsData modelSnsData = ModelSnsData(
        uid: socialKey,
        loginType: LoginType.kakao,
        nickname: kakaoProfile[keyProperties][keyNickname],
        email: kakaoProfile[keyProperties][keyEmail] ?? '',
      );*/

      FirebaseFirestore.instance.collection(keyUser).doc(socialKey).get().then(
            (value) {
          /// 아이디가 있을때, 로그인
          if (value.exists) {
            Utils.log.i('로그인 성공');
          }

          /// 회원가입
          else {
            Utils.log.i('로그인 성공');
          }
        },
      ).onError((e, s) {});
    } catch (e, s) {}
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
