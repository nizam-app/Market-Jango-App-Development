import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';

void main() {

  runApp( ScreenUtilInit(
    designSize: const Size(393, 852),
    minTextAdapt: true,
    splitScreenMode: true,
      child: App()));
}