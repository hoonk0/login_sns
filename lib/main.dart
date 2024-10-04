import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:login_sns/login.dart';

// com.appdoggaebi.englishQuiz
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

/*
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    initializeDateFormatting(),
  ]);
*/
  KakaoSdk.init(
    nativeAppKey: '5014ea1cbf4ae7165bb82aaf1ca8a829',
    javaScriptAppKey: '202c857c0e5ba386e30402a01924efc0',
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RouteAuthLogin(),
    );
  }
}
