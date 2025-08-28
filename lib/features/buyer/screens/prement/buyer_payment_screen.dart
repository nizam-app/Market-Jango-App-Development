import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
class BuyerPaymentScreen extends StatelessWidget {
  const BuyerPaymentScreen({super.key});
  static final routeName = "/buyerPaymentScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Tuppertextandbackbutton(screenName: "Payment")
            
          ],
        ),
      )),
    );
  }
}