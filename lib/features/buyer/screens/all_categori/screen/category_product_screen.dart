import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/widget/custom_textfromfield.dart';
import 'package:market_jango/features/buyer/screens/vandor/vandor_profile_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';
class CategoryProductScreen extends StatelessWidget {
  const CategoryProductScreen({super.key});
  static final String routeName = '/categoryProductScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SearchBarSection(),
            // Padding(
            //   padding:  EdgeInsets.symmetric(horizontal: 20.w,),
            //   child: Tuppertextandbackbutton(screenName: "All Products"),
            // ),
            Padding(
              padding:  EdgeInsets.only(left: 20.w, right: 20.w,bottom: 10.h),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.r),
                  child: const CustomTextFromField(hintText: "Search your vendor",prefixIcon: Icons.search,)),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
              child: Text("Trend Loop",style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24.sp),),
            ),
            Expanded(
              child: Row(
                children: [
                  const VendorListSection(),
                  Expanded(child: const ProductGridSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------- Custom Codebase ----------------------

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search your vendor",
          prefixIcon: Icon(Icons.search, color: AllColor.grey),
          filled: true,
          fillColor: AllColor.grey200,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class VendorListSection extends StatelessWidget {
  const VendorListSection({super.key});

  final vendors = const [
    {"name": "TrendLoop", "icon": "https://i.pravatar.cc/100?img=1"},
    {"name": "Style Street", "icon": "https://i.pravatar.cc/100?img=2"},
    {"name": "Louis Vuitton", "icon": "https://i.pravatar.cc/100?img=3"},
    {"name": "MasterCard", "icon": "https://i.pravatar.cc/100?img=4"},
    {"name": "Starbucks", "icon": "https://i.pravatar.cc/100?img=5"},
    {"name": "Gillette", "icon": "https://i.pravatar.cc/100?img=6"},
    {"name": "IBM", "icon": "https://i.pravatar.cc/100?img=7"},
    {"name": "McDonalds", "icon": "https://i.pravatar.cc/100?img=8"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110.w,
      color: AllColor.grey500,
      child: ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(height: 10.h),
              InkWell(
                onTap: ()=>goToVendorProfileScreen(context),
                child: CircleAvatar(
                  radius: 28.r,
                  backgroundImage: NetworkImage(vendors[index]["icon"]!),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                vendors[index]["name"]!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10.h),
            ],
          );
        },
      ),
    );
  }
  void goToVendorProfileScreen(BuildContext context) {
    context.push( VendorProfileScreen.routeName);
  }
}

class ProductGridSection extends StatelessWidget {
  const ProductGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.5,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ProductCard(
          title: "Style meets comfort.",
          price: 128.00,
          imageUrl:
          "https://images.unsplash.com/photo-1514996937319-344454492b37?q=80&w=3087&auto=format&fit=crop",

          storeName: "R2A Store",
          memberSince: "Member Since 2014",
          storeImage:
          "https://randomuser.me/api/portraits/men/32.jpg", // demo avatar
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;
  final String storeName;
  final String memberSince;
  final String storeImage;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.storeName,
    required this.memberSince,
    required this.storeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Discount
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                child: Image.network(
                  imageUrl,
                  height: 130.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: CustomDiscountCord(), // ✅ Custom widget
              ),
            ],
          ),

          // Text + Store Info
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AllColor.black)),
                SizedBox(height: 3.h),
                Text(
                  "\$$price",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8.r,
                      backgroundImage: NetworkImage(storeImage),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(storeName,
                            style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,color: AllColor.black)),
                        Text(
                            memberSince.length > 12
                                ? '${memberSince.substring(0, 12)}...'
                                : memberSince,
                            style: TextStyle(
                                fontSize: 10.sp, color: AllColor.grey)),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
