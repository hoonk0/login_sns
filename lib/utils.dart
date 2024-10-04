import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';


class Utils {
  /// 구글 로그인 함수

  static final log = Logger(printer: PrettyPrinter(methodCount: 1));

  static Future<UserCredential?> onGoogleTap() async {
    GoogleSignInAccount? account;
    Fluttertoast.showToast(msg: '  auth trying  \n  wait please  ');

    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      debugPrint("googleSignIn ${googleSignIn.serverClientId} ${googleSignIn
          .clientId}");
      account = await googleSignIn.signIn();

      if (account != null) {
        debugPrint('account ${account.email}');
        GoogleSignInAuthentication authentication = await account
            .authentication;
        debugPrint('account 22');
        OAuthCredential googleCredential = GoogleAuthProvider.credential(
          idToken: authentication.idToken,
          accessToken: authentication.accessToken,
        );
        debugPrint('googleCredential ${googleCredential.providerId}');
        final credential = await FirebaseAuth.instance.signInWithCredential(
            googleCredential);
        debugPrint('로그인 이메일 ${credential.user!.email}');

        if (credential.user != null) {
          // 로그인 성공 시
          Fluttertoast.showToast(msg: '  Google auth success  ');
          Utils.log.i('구글 인증 성공\구글 사용자: ${FirebaseAuth.instance.currentUser}');
          return credential;
        } else {
          debugPrint('account null');
          return null;
        }
      } else {}
    } on FirebaseAuthException catch (e, s) {
      Utils.log.f('구글 인증 실패\n${e.code}\n$s');
      if (e.code == 'invalid-email') {
        Utils.toast(desc: 'confirm email format');
      } else if (e.code == 'user-disabled') {
        Utils.toast(desc: 'this account is disabled');
      } else if ((e.code == 'user-not-found') || (e.code == 'wrong-password')) {
        Utils.toast(desc: 'confirm password');
      } else if (e.code == 'too-many-requests') {
        Utils.toast(desc: 'too many requests');
      } else {
        Utils.toast(desc: '  Google auth fail  \n  error: ${e.code}  ');
      }
    }
  }

  /// 토스트 메세지
  //static final log = Logger(printer: PrettyPrinter(methodCount: 1));

  static void toast({
    required String desc,
    int duration = 1000,
    bool hasIcon = false,
  }) {
    Fluttertoast.showToast(msg: desc, gravity: ToastGravity.SNACKBAR);
  }

  static final regExpPw = RegExp(r'.{6,}');

/*
  static Future<bool> logout() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove(keyUid);
    Global.uid = null;
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      return true;
    } catch (e) {
      Utils.toast(desc: 'Logout fault ${e.toString()}');
      return false;
    }
  }

  static initializeProviders(WidgetRef ref) {}*/

  static Future<bool> sendEmail(String to, String subject,
      String content) async {
    final url = Uri.parse(
        'https://asia-northeast3-chater-quiz-book.cloudfunctions.net/sendEmail');

    final response = await http.get(url.replace(queryParameters: {
      'to': to,
      'subject': subject,
      'content': content,
    }));

    if (response.statusCode == 200) {
      print("Email sent successfully.");
      return true;
    } else {
      print("Failed to send email: ${response.statusCode}");
      print("Error: ${response.body}");
      return false;
    }
  }

/*  static Future<UserCredential?> onAppleTap() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      AuthorizationCredentialAppleID authorizationCredentialAppleID = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
          webAuthenticationOptions: WebAuthenticationOptions(
              clientId: 'gather.appdoggaebi.ios',
              redirectUri: Uri.parse('https://able-tangible-thrill.glitch'
                  '.me/callbacks/sign_in_with_apple')));

      Utils.log.d(
          "authorizationCredentialAppleID 결과 : ${authorizationCredentialAppleID.email}, ${authorizationCredentialAppleID.givenName}, ${authorizationCredentialAppleID.familyName}");

      // Create an `OAuthCredential` from the credential returned by Apple.
      OAuthCredential oauthCredential = OAuthProvider("apple.com").credential(
        idToken: authorizationCredentialAppleID.identityToken,
        accessToken: authorizationCredentialAppleID.authorizationCode,
        rawNonce: rawNonce,
      );

      Utils.log.d("oauthCredential 결과 : ${oauthCredential.idToken}");

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final credential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (credential.user != null) {
        // 로그인 성공시
        Fluttertoast.showToast(msg: '  Apple login success  ');
        Utils.log.i('애플 로그인 성공\n애플 사용자: ${FirebaseAuth.instance.currentUser}  credential $credential');
        return credential;
      } else {
        // 로그인 실패시
        Fluttertoast.showToast(msg: '  Apple login fail ');
        Utils.log.f('애플 로그인 실패\n credential.user == null');
        return null;
      }
    } on FirebaseAuthException catch (e, s) {
      Fluttertoast.showToast(msg: '  Apple login fail  \n  ${e.code}  ');
      Utils.log.f('애플 로그인 실패\n${e.code}\n$s');
    }
  }*/

/*  static String generateNonce([int length = 32]) {
    String charset = 'kr.co.kayple.today_safety@${DateTime.now().millisecondsSinceEpoch}';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }*/
/*
  /// Returns the sha256 hash of [input] in hex notation.
  /// 애플 로그인 보안 관련 코드
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }*/

  /// 카카오 로그인 함수
  static Future<String?> onKakaoTap() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Fluttertoast.showToast(msg: '카카오 로그인을 시도중입니다.');

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
          Utils.toast(desc: '카카로 로그인에 실패했어요\n다른 로그인 방법을 이용해주세요. CANCELED');
        }
        return null;
      }
    }
    // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
    else {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
      } catch (e, s) {
        Utils.log.f('카카오 계정으로 로그인 실패\n$e\n$s');
        Utils.toast(desc: '카카로 로그인에 실패했어요\n다른 로그인 방법을 이용해주세요');
        return null;
      }
    }
    dynamic kakaoProfile;

    // [3] 카카오 유저정보 가져오기
    try {
      final url = Uri.https('kapi.kakao.com', '/v2/user/me');
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}'
        },
      );

      kakaoProfile = json.decode(response.body);
      Utils.log.d('프로필 정보 : ${kakaoProfile.toString()}');
    } catch (e, s) {
      Utils.log.f('카카오 유저정보 가져오기 실패\n$e\n$s');
      Utils.toast(desc: '카카오 유저정보를 가져오는데 실패했어요\n다른 로그인 방법을 이용해주세요');
    }

    // [4] token을 이용하여 파이어베이스에 인증
    try {
      final String uid = 'kakao:${kakaoProfile['id']}';
      return uid;
    } catch (e, s) {
      Utils.toast(desc: '카카오 로그인에 실패하였습니다\n다시 시도해주세요');
      Utils.log.f('카카오 로그인 실패\n$e\n$s');
      return null;
    }
  }

/*  static final Throttler throttler = Throttler(milliseconds: 200);

  static String pickAnswer(ModelQuiz modelQuiz) {
    if (modelQuiz.choiceAnswer == Choice.a) {
      return modelQuiz.choiceA;
    }
    if (modelQuiz.choiceAnswer == Choice.b) {
      return modelQuiz.choiceB;
    }
    if (modelQuiz.choiceAnswer == Choice.c) {
      return modelQuiz.choiceC;
    }
    return modelQuiz.choiceD;
  }

  static int checkIsStudyDay(DateTime date) {
    final listDate = Global.userNotifier.value!.listStudyComplete.map((e) => e.dateComplete.toDate());
    final listDateOnly = listDate.map((e) => DateTime(e.year, e.month, e.day));
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dateCount = listDateOnly.where((date) => isSameDay(date, dateOnly)).length;
    return dateCount;
  }*/

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

/*  static Future<void> uploadStudyCompleteBook({
    required ModelBook modelBook,
    required int countRightAnswer,
    required int listModelQuizLength,
  }) async {
    final listStudyComplete = Global.vnListBookStudyComplete.value.map((e) => e.uid);
    if (!listStudyComplete.contains(modelBook.uid) && countRightAnswer / listModelQuizLength >= 0.7) {
      final modelStudyComplete = ModelStudyComplete(dateComplete: Timestamp.now(), bookUid: modelBook.uid);
      debugPrint("Global.uid ${Global.uid}");
      FirebaseFirestore.instance.collection(keyUser).doc(Global.uid).update({
        keyListStudyComplete: FieldValue.arrayUnion([modelStudyComplete.toJson()])
      });
    }
  }*/
}