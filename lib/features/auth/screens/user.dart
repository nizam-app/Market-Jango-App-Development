import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  static const String routeName = '/userScreen';  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
 body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
             IconButton(onPressed: (){
           context.pop(); 
        }, icon:Icon(Icons.arrow_back_ios)),
        
            ],
          ),),
        ),
      ),
    );
  }
}