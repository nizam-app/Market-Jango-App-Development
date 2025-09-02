import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VendorMyProductScreen extends StatelessWidget {
  const VendorMyProductScreen({super.key});
    static const routeName = "/vendorMyProductScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Section title
              Text(
                "My Products",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),

              /// Add Product and Add Category
              Row(
                children: [
                  _AddBox(
                    title: "Add your\nProduct",
                    onTap: () {},
                  ),
                  SizedBox(width: 12.w),
                  _AddBox(
                    title: "Add your\nCategory",
                    onTap: () {},
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              /// Add custom attribute
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Add your custom attribute"),
                      const Icon(Icons.add),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Products List
              Text(
                "Products List",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),

              /// Product items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  return _ProductCard(
                    title: "Flowy summer dress",
                    category: "Fashion",
                    price: "\$65",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add Box Widget
class _AddBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AddBox({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 30),
              SizedBox(height: 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product Card
class _ProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;

  const _ProductCard({
    required this.title,
    required this.category,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          /// Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          /// Price
          Text(
            price,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 6.w),

          /// Menu icon
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
