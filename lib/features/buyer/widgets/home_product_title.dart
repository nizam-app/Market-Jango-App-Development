import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePorductTitel extends StatelessWidget {
  const HomePorductTitel({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Text(
        name[0].toUpperCase() + name.substring(1),
        style: Theme.of(
          context,
        ).textTheme.titleLarge!.copyWith(fontSize: 24.sp),
      ),
    );
  }
}
