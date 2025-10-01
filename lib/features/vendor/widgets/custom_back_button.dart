import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
        onTap: (){
     context.pop() ;
    },
    child: Container(
      height: 24.w,
      width: 24.w,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:Color(0xffF5F4F8)
      ),
      child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 10.r,),



    ));
  }
}