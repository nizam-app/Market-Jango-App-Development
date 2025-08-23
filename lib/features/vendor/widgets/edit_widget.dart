import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Edit_Widget extends StatelessWidget {
  const Edit_Widget({
    super.key, required this.height, required this.width, required this.size,
  });
  final double height;
  final double width;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){

      },
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle
        ),
        child: ImageIcon(AssetImage("assets/icon/edit_ic.png"),size: size,),
      ),
    );
  }
}