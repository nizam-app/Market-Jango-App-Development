import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/review/review_screen.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_see_all_product.dart';
class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});
  static final String routeName = '/vendorProfileScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
        CustomVendorUpperSection(),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: [
                  SeeMoreButton(name: "All Products", isSeeMore: false, ),
                  PopularProduct(),
        
                  SeeMoreButton(name: "Fashion", seeMoreAction: () {}, ),
                  FashionProduct(),
                  SeeMoreButton(name: "Electronics", seeMoreAction: () {}, ),
                  FashionProduct()
        
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}


class CustomVendorUpperSection extends StatelessWidget {
  const CustomVendorUpperSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Icon(Icons.arrow_back_ios)),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              CircleAvatar(
                radius: 35.r,
                backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1607746882042-944635dfe10e",
                ),
              ),
              SizedBox(height: 8.h),

              // Name + Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TrendLoop",
                    style:theme.headlineMedium!.copyWith(fontWeight: FontWeight.w600) ,
                  ),
                  SizedBox(width: 5.w),
                  Icon(Icons.location_on, size: 16.sp, color: Colors.red),
                  Text(
                    "Dhaka",
                    style:theme.titleMedium,
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Opening time
              Text(
                "Opening time: 8:00 am - 7:00 pm",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8.h),

              // Rating + Review count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarRating(
                    rating: 4.6,
                      color: Colors.amber,
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                    goToReviewScreen(context);
                    },
                    child: Text(
                      "4.6 ( 66 reviews )",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Spacer()
        ],
      ),
    );
  }
  void goToReviewScreen( BuildContext context){
    context.push(ReviewScreen.routeName);
  }
}

class FashionProduct extends StatelessWidget {
  const FashionProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
          shrinkWrap: true,
          physics:AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          // Example item count
          itemBuilder: (context, index) {
            return CustomNewProduct(width: 130.w, height: 138.h);}
      ),
    );
  }
}
class PopularProduct extends StatelessWidget {
  const PopularProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // mainAxisSpacing: 0.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.62.h,
        ),
        itemCount: 4,
        // Example item count
        itemBuilder: (context, index) {
          return CustomNewProduct(width: 162.w, height: 172.h);
        });
  }
}
