import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/constants/color_control/theme_color_controller.dart';
import 'package:market_jango/core/theme/text_theme.dart';
import 'input_decoration_theme.dart';
import 'logic/theme_changer.dart';
final ThemeChanger _themeController = Get.put(ThemeChanger());
ThemeData themeMood(){
  Brightness brightness = _themeController.isDarkMode.value? Brightness.light : Brightness.dark;
  return ThemeData(
  brightness:brightness,
  colorScheme: ColorScheme.light(
    brightness: brightness,
      primary: AllColor.yellow500,
      onPrimary:_themeController.isDarkMode.value?  AllColor.white :ThemeColorController.black,
      secondary:ThemeColorController.green,
      onSecondary:_themeController.isDarkMode.value? AllColor.white:ThemeColorController.black,
      surface:  ThemeColorController.grey,
      onSurface:_themeController.isDarkMode.value? ThemeColorController.black:AllColor.white),
inputDecorationTheme: inputDecorationTheme,
  useMaterial3: true,
  // scaffoldBackgroundColor: _themeController.isDarkMode.value? ThemeColorController.white: ThemeColorController.black,
    textTheme: textTheme
);
}
