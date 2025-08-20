import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});
static final String routeName = '/productDetails';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      SafeArea(child:
      SingleChildScrollView(
        child: Column(
          children: [
            ProductImage(),
            CustomSize()
        ],
        ),
      ),
      ),
    );
  }
}
class ProductImage extends StatelessWidget {
  const ProductImage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      children: [
        // 🔹 Product Image with Back Button
        Stack(
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1470&auto=format&fit=crop",
              height: 350.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              child: CircleAvatar(
                backgroundColor: AllColor.white,
                child:IconButton(onPressed: (){context.pop();}, icon:  Icon(Icons.arrow_back, color: AllColor.black)),
              ),
            ),
          ],
        ),

        // 🔹 White Container with Product Details

      ],
    );
  }
}
class CustomSize extends StatefulWidget {
  const CustomSize({super.key});

  @override
  State<CustomSize> createState() => _CustomSizeState();
}

class _CustomSizeState extends State<CustomSize> {
  final List<String> sizes = ["XS", "S", "M", "L", "XL", "2XL"];
  int selectedIndex = 2; // Default selected = "M"

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding:  EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\$15.00",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Everyday Elegance in Women’s Fashion",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Discover a curated collection of stylish and fashionable "
                      "women's dresses designed for every mood and moment. "
                      "From elegant evenings to everyday charm — dress to express.",
                  style: theme.titleMedium,
                ),
              ],
            ),
          ),

          buildText("Size"),


          // 🔹 Container background
          Container(
            padding: EdgeInsets.symmetric( horizontal: 8.w,vertical: 3.h),
            decoration: BoxDecoration(
              color: AllColor.lightBlue.withOpacity(0.15), // light blue background
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(sizes.length, (index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color:isSelected? AllColor.white : AllColor.transparent,
                      borderRadius: BorderRadius.circular(50.r),
                      border: isSelected
                          ? Border.all(color: AllColor.blue, width: 3.w)
                          : null,
                    ),
                    child: Text(
                      sizes[index],
                      style: TextStyle(
                        fontSize:isSelected? 16.sp:13.sp,
                        fontWeight:isSelected? FontWeight.bold: FontWeight.w500,
                        color: isSelected ? AllColor.blue : AllColor.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          buildText("Color"),
          CustomColor()
        ],
      ),
    );
  }

  Widget buildText(String text) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Text(
              "$text",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.black,
              ),
            ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class CustomColor extends StatefulWidget {
  const CustomColor({super.key});

  @override
  State<CustomColor> createState() => _CustomColorState();
}

class _CustomColorState extends State<CustomColor> {
  final List<Color> colors = [
    Colors.grey.shade300,
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.purple,
  ];

  int selectedIndex = 0; // default selected

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.transparent,
                  width: 3.w,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Color Circle
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.w),
                    ),
                  ),
                  // ✅ Check Icon if selected
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 25.sp,
                      color: Colors.white,
                      weight: 900, // This makes the icon bold
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
