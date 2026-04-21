import 'package:flutter/material.dart';

import '../constants/app_color.dart';

ThemeData getTheme() => ThemeData(
  scaffoldBackgroundColor: AppColor.backgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColor.backgroundColor,
    centerTitle: true,
  ),
  iconTheme: IconThemeData(
    color: AppColor.textSecondaryColor,
    size: 24,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: AppColor.backgroundColor,
      fontSize: 32,
      fontWeight: FontWeight.bold
    ),
    titleLarge: TextStyle(
      color: AppColor.textColor,
      fontSize: 20,
      fontWeight: FontWeight.bold
    ),
    bodyLarge: TextStyle(
      color: AppColor.textColor,
      fontSize: 18,
      fontWeight: FontWeight.w600
    ),
    bodySmall: TextStyle(
      color: AppColor.textSecondaryColor,
      fontSize: 14,
      fontWeight: FontWeight.w400
    )
  )
);