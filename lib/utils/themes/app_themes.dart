import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.blackColor,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.blueColor,
    brightness: Brightness.dark,
    background: AppColors.searchBarBg,
    tertiary: AppColors.textColor1,
  ),
  textTheme: const TextTheme(
    headline1: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    headline2: TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
    ),
    bodyText1: TextStyle(
      fontSize: 14.0,
      color: AppColors.blueColor,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    // showUnselectedLabels: true,
    selectedItemColor: AppColors.blueColor,
    selectedLabelStyle: TextStyle(color: AppColors.blueColor),
    selectedIconTheme: IconThemeData(color: AppColors.blueColor),
    unselectedIconTheme: IconThemeData(color: AppColors.textColor1),
    unselectedItemColor: AppColors.textColor1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.blackColor,
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: Colors.pink,
  ),
);

class AppColors {
  static const blackColor = Color(0xFF1b1b1b);
  static const blueColor = Color(0xFF5c9de9);
  static const textColor1 = Color(0xFFbccad0);
  static const searchBarBg = Color(0xFF292929);
}
