import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});
  static final String routeName = '/reviewScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Tuppertextandbackbutton(screenName: "Review Screen"),
            Flexible(child: ReviewSection())
          ],
        ),
      )),
    );
  }
}
class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20, // number of reviews
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return const CustomReview();
      },
    );
  }
}

class CustomReview extends StatelessWidget {
  const CustomReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 24.r,
            backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/women/44.jpg",
            ),
          ),
          SizedBox(width: 12.w),

          // Review Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Veronika",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),

                // ⭐ Star Rating
                Row(
                  children: [
                    StarRating(
                      rating: 3.5,
                      allowHalfRating: true,

                    ),
                    Spacer()
                  ],
                ),
                SizedBox(height: 6.h),

                // Review Text
                Text(
                  "Lorem ipsum dolor sit amet, consectetur sadipscing elitr, "
                      "sed diam nonumy eirmod tempor invidunt ut labore et dolore "
                      "magna aliquyam erat, sed diam voluptua. At vero eos et "
                      "accusam et justo duo dolores et ea rebum.",
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
