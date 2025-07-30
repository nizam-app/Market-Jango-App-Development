import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class LocationFilterPage extends StatelessWidget {
  const LocationFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    String? selectedCountry = 'Bangladesh';
    String? selectedCategory = 'Fashion';
    TextTheme theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.32),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: Container(
              color: Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 20.h),
              decoration:  BoxDecoration(
                color:AllColor.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                   SizedBox(height: 10.h),

                  // Country Dropdown
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Your country",style: theme.headlineMedium!.copyWith(fontSize: 14),),
                  ),
                   SizedBox(height: 5.h),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    decoration:  buildInputDecoration(),
                    items: ['Bangladesh', 'India', 'USA']
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country,style: theme.headlineMedium,),
                    ))
                        .toList(),
                    onChanged: (value) {},
                  ),

                   SizedBox(height: 20.h),

                  // Location Search Field
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Enter your Location",style: theme.headlineMedium!.copyWith(fontSize: 14),),
                  ),
                   SizedBox(height: 5.h),
                   TextField(
                    decoration: buildInputDecoration()!.copyWith(
                        hintText: "Search your location",
                        prefixIcon: Icon(Icons.search_rounded,size: 27.sp,),
                    fillColor: AllColor.gray100),
                  ),

                   SizedBox(height: 20.h),

                  // Category Dropdown
                   Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Categories",style: theme.headlineMedium!.copyWith(fontSize: 14),),
                  ),
                   SizedBox(height: 5.h),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: buildInputDecoration(),
                    items: ['Fashion', 'Electronics', 'Grocery']
                        .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category,style: theme.headlineMedium,),
                    ))
                        .toList(),
                    onChanged: (value) {},
                  ),

                   SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
                    filled: true,
                    fillColor: AllColor.dropDown,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey),
                    )
                    );
  }
}
