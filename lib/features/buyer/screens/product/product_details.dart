import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/review/review_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_new_items_show.dart';
import 'package:market_jango/features/buyer/widgets/custom_top_card.dart';
class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});
  static final String routeName = '/productDetails';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProductImage(),
              CustomSize(),
              ProductMaterialAndStoreInfo(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  children: [
                    const SeeMoreButton(name: "Top Products", seeMoreAction: null, isSeeMore: false),
                    CustomTopProducts(),
                    SeeMoreButton(name: "New Items", seeMoreAction: (){context.pushNamed(
                        SeeJustForYouScreen.routeName, pathParameters: {"screenName": "New Items"});}),
                    const CustomNewItemsShow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔶 Bottom bar you wanted
      bottomNavigationBar: QuantityBuyBar(
        onBuyNow: (qty) {
          // TODO: handle buy action
          // e.g. context.push('/checkout?qty=$qty');
        },
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

          SizeColorAnd(text: "Size"),


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
          SizeColorAnd(text: "Color"),
          CustomColor()
        ],
      ),
    );
  }
}

class SizeColorAnd extends StatelessWidget {
  const SizeColorAnd({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
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
        SizedBox(height: 10.h),
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
class ProductMaterialAndStoreInfo extends StatelessWidget {
  const ProductMaterialAndStoreInfo({
    super.key,
    this.materials = const [
      MaterialChip(text: 'Cotton 95%'),
      MaterialChip(text: 'Nylon 5%'),
    ],
    this.storeName = 'R2A Store',
    this.rating = 4.6,
    this.reviewCount = 56,
    this.onChatTap,
  });

  final List<MaterialChip> materials;
  final String storeName;
  final double rating;
  final int reviewCount;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal:20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Materials row
          SizeColorAnd(text: "Specifications",)  ,
          
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: materials
                .map((m) => _MaterialPill(text: m.text))
                .toList(),
          ),
          SizedBox(height: 14.h),

          // Store + chat
          Row(
            children: [
              InkWell(onTap: (){context.push(BuyerVendorProfileScreen.routeName);},
                child: CircleAvatar(radius: 25,
                backgroundImage: AssetImage("assets/images/promo2.jpg"),),
              ),
              SizedBox(width: 20.w,)    ,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){context.push(BuyerVendorProfileScreen.routeName);},
                    child: Text(
                      storeName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Rating line
                  Row(
                    children: [
                      Icon(Icons.star, size: 14.r, color: AllColor.orange),
                      SizedBox(width: 4.w),

                      // Numeric rating
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AllColor.black,
                        ),
                      ),
                      SizedBox(width: 6.w),

                      // Small badge around review count like in screenshot
                      InkWell(
                        onTap: (){context.push(ReviewScreen.routeName);},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            // color: AllColor.badgeBg,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: AllColor.black, width: 0.8),
                          ),
                          child: Text(
                            '$reviewCount reviews',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AllColor.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
              Spacer(),
              InkWell(
                onTap: onChatTap,
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16.r,
                        color: AllColor.blue,
                      ),
                      SizedBox(width: 5.w,),
                      InkWell(
                        onTap: (){context.push(ChatScreen.routeName);},
                          child: Text("Chat naw",style: TextStyle(color: Colors.blue,fontSize: 12),))
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        
        ],
      ),
    );
  }
}

/// Single yellow rounded pill
class _MaterialPill extends StatelessWidget {
  const _MaterialPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AllColor.orange200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AllColor.black,
        ),
      ),
    );
  }
}

/// Helper to pass materials easily
class MaterialChip {
  final String text;
  const MaterialChip({required this.text});
}
class QuantityBuyBar extends StatefulWidget {
  const QuantityBuyBar({
    super.key,
    this.min = 1,
    this.max = 99,
    required this.onBuyNow,
  });

  final int min;
  final int max;
  final void Function(int qty) onBuyNow;

  @override
  State<QuantityBuyBar> createState() => _QuantityBuyBarState();
}

class _QuantityBuyBarState extends State<QuantityBuyBar> {
  int qty = 1;

  void _dec() {
    if (qty > widget.min) setState(() => qty--);
  }

  void _inc() {
    if (qty < widget.max) setState(() => qty++);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8.r,
            offset: Offset(0, -3.h),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          // — qty +
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _QtyIcon(onTap: _dec, child: Text('−', style: TextStyle(fontSize: 16.sp))),
                SizedBox(width: 10.w),
                Text('$qty', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                SizedBox(width: 10.w),
                _QtyIcon(onTap: _inc, child: Text('+', style: TextStyle(fontSize: 16.sp))),
              ],
            ),
          ),
       Spacer() ,

          // 🔶 Buy now button (vertically same, horizontally smaller)
          SizedBox(
            width: 180.w,   // ⬅️ fixed width, not Expanded → horizontally smaller
            height: 44.h,   // ⬅️ vertical same as আগে
            child: ElevatedButton(
              onPressed: () {context.push(BuyerPaymentScreen.routeName);},
              style: ElevatedButton.styleFrom(
                backgroundColor: AllColor.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Buy now',
                style: TextStyle(
                  color: AllColor.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyIcon extends StatelessWidget {
  const _QtyIcon({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: child,
      ),
    );
  }
}