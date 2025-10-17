// // light_dark_theme.dart  (or your existing theme file)
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:market_jango/core/constants/color_control/all_color.dart';
// import 'package:market_jango/core/constants/color_control/theme_color_controller.dart';
// import 'package:market_jango/core/theme/text_theme.dart';
// import 'input_decoration_theme.dart';
//
// /// mirrors your old `isDarkMode = true`
// final isDarkProvider = StateProvider<bool>((_) => true);
//
// /// Build ThemeData from current isDark flag (keeps your original mapping:
// /// true -> Brightness.light, false -> Brightness.dark)
// final themeDataProvider = Provider<ThemeData>((ref) {
//   final isDark = ref.watch(isDarkProvider);
//   final brightness = isDark ? Brightness.light : Brightness.dark;
//
//   return ThemeData(
//     brightness: brightness,
//     colorScheme: ColorScheme.light(
//       brightness: brightness,
//       primary: AllColor.orange500,
//       onPrimary: isDark ? AllColor.white : ThemeColorController.black,
//       secondary: ThemeColorController.green,
//       onSecondary: isDark ? AllColor.white : ThemeColorController.black,
//       surface: ThemeColorController.grey,
//       onSurface: isDark ? ThemeColorController.black : AllColor.white,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AllColor.orange50,
//       contentPadding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 20.w),
//       // prefixIconColor: Colors.grey,
//       hintStyle: TextStyle(color: AllColor.textHintColor, fontSize: 14.sp,fontWeight: FontWeight.w400,),
//       suffixIconColor: Colors.grey,
//       // border:  OutlineInputBorder(
//       //     borderRadius: BorderRadius.circular(50),
//       //     borderSide: BorderSide(color: AllColor.textBorderColor, width: 0.5.sp),
//       //   ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(50),
//         borderSide: BorderSide(color: AllColor.textBorderColor, width: 0.5.sp),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(50),
//         borderSide: BorderSide(color: AllColor.textBorderColor, width: 0.5.sp),
//       ),
//       // errorBorder: OutlineInputBorder(
//       //   borderRadius: BorderRadius.circular(50),
//       //   borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
//       // ),
//       // focusedErrorBorder: OutlineInputBorder(
//       //   borderRadius: BorderRadius.circular(50),
//       //   borderSide: BorderSide(color: AllColor.red200, width: 0.5.sp),
//       // ),
//       // errorStyle: TextStyle(fontSize: 12.sp, color: Colors.red),
//
//     ),
//     useMaterial3: true,
//     textTheme: TextTheme(
//       titleLarge: TextStyle(
//         fontSize: 28.sp,
//         fontWeight: FontWeight.w500,
//       ),
//       titleMedium: TextStyle(
//         fontSize: 12.sp,
//         color: AllColor.green300,
//         fontWeight: FontWeight.w400,
//         // letterSpacing: 1
//       ),
//       titleSmall: TextStyle(
//           fontSize: 17.sp,
//           fontWeight: FontWeight.w600,
//           color: AllColor.green500
//       ),
//       headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AllColor.black),
//       headlineMedium: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w400
//       ),
//
//
//     ),
//   );
// });
//
// /// Keep your old API name but now it needs `ref`
// ThemeData themeMood(WidgetRef ref) => ref.watch(themeDataProvider);
//
// /// Toggle helper (drop-in for your old controller’s `toggleTheme`)
// void toggleTheme(WidgetRef ref) =>
//     ref.read(isDarkProvider.notifier).update((v) => !v);
// theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'input_decoration_theme.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AllColor.orange500,
  scaffoldBackgroundColor: AllColor.white,
  colorScheme: ColorScheme.light(
    primary: AllColor.orange500,
    onPrimary: AllColor.white,
    secondary: AllColor.green500,
    onSecondary: AllColor.white,
    surface: AllColor.grey,
    onSurface: AllColor.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AllColor.orange50,
    contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
    hintStyle: TextStyle(
      color: AllColor.textHintColor,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    suffixIconColor: Colors.grey,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: AllColor.textBorderColor, width: 0.5.sp),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: AllColor.textBorderColor, width: 0.5.sp),
    ),
  ),
  useMaterial3: true,
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w500, color: AllColor.black),
    titleMedium: TextStyle(fontSize: 12.sp, color: AllColor.green300, fontWeight: FontWeight.w400),
    titleSmall: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600, color: AllColor.green500),
    headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AllColor.black),
    headlineMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: AllColor.black),
  ),
);
