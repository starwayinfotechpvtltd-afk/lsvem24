import 'package:flutter/material.dart';

abstract class AppColor {
  // ************** Main Colors ***************

  static const Color primaryColor = Color(0xFFFF4D67);
  static const Color white = Colors.white;
  static const Color black = Colors.black; // Color(0xFF212121)
  static const Color transparent = Colors.transparent; // Color(0xFF212121)
  static const Color lightPink = Color(0xFFFF8395);
  static const Color lightPinkBG = Color(0xFFFFF8F9);
  static const Color lightGreyBG = Color(0xFFFAFAFA);

  static const Color orangeColor = Color(0xFFFF981F);
  static const Color orangeTextColor = Color(0xFFF99300);
  static const Color lightOrangeBG = Color(0xFFFFF2D4);

  static const pinkLinearGradient = LinearGradient(colors: [Color(0xFFFF8395), Color(0xFFFF4D67)]); // ************** Grey Related Colors ***************.

  static const Color grey = Color(0xff9e9e9e);
  static const Color greyColor = Color(0xFF757575);

  static Color grey_50 = Colors.grey.shade50;
  static Color grey_100 = Colors.grey.shade100; // Color(0xffEEEEEE)
  static Color grey_200 = Colors.grey.shade200;
  static Color grey_300 = Colors.grey.shade300;
  static Color grey_400 = Colors.grey.shade400;

  static const Color dotColor = Color(0xFFE0E0E0);

  static const Color lightGreen = Color(0xFFD7FFDD);
  static const Color lightGreen1 = Color(0xFF85FF97);
  static const Color darkGreen = Color(0xFF4AAF57);

  static const Color lightRed = Color(0xFFFFD7D7);
  static const Color lightRed1 = Color(0xFFFF8585);
  static const Color darkRed = Color(0xFFD72929);

  static const Color darkGrey = Color(0xFF4C4B4B);

  static const Color green = Colors.green;
  static const Color yellow = Colors.amber;

  // static const Color bottomLineColor = Color(0xFF9E9E9E);

  static const Color logOutColor = Color(0xffF75555);
  static const Color validityColor = Color(0xff616161);
  static const Color cardButtonColor = Color(0xffFFEDF0);

  static const Color mainDark = Color(0xFF181A20);
  static const Color secondDarkMode = Color(0xFF1F222A);
// static const Color DarkMode_Third = Color(0xff35383F);
}
