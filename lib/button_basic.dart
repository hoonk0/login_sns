import 'package:flutter/material.dart';

class ButtonBasic extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final double width;
  final Color titleColorBg;
  final Color? colorBg; // 사용자가 입력할 수 있는 색상 변수
  final void Function()? onTap;
  final double circularSize; // double로 수정

  const ButtonBasic({
    required this.title,
    this.width = double.infinity,
    this.titleColorBg = Colors.white,
    this.titleFontSize = 16,
    this.colorBg, // 여기서 기본값은 null로 설정
    required this.onTap,
    this.circularSize = 100, // 기본값 설정
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(circularSize)),
          gradient: colorBg == null // colorBg가 null인 경우 기본 그라데이션 사용
              ? const LinearGradient(
            colors: [Color(0xFF9A00E2), Color(0xFFF2095D)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
              : null, // 그라데이션이 아닌 경우 기본 색상 사용
          color: colorBg ?? Colors.black, // colorBg가 설정된 경우 해당 색상 사용, 기본 검정색
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
              color: titleColorBg,
            ),
          ),
        ),
      ),
    );
  }
}
