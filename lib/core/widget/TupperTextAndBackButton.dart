import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
class Tuppertextandbackbutton extends StatelessWidget {
  const Tuppertextandbackbutton({super.key ,required this.screenName});
final String screenName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: EdgeInsets.symmetric( vertical:16.h),
          child: Row(
            children: [
              InkWell(
                onTap: (){backButton(context);},
                child: CircleAvatar(
                    radius: 15.r,
                    backgroundColor: AllColor.gray300,
                    child: Icon(Icons.arrow_back_ios, size: 8.sp,color: AllColor.black,)),
              ),
              Spacer(),

              Text(
                '$screenName',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
              Spacer()
            ],
          ),
        ),
        SizedBox(height: 10.h,),
      ],
    );
  }
  void backButton (BuildContext context) {
    context.pop();
  }
}
