import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_top_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logic/add_cart_quantity_logic.dart';
import 'logic/product_details_data.dart';
import 'model/product_all_details_model.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({super.key, required this.productId});
  final int productId;
  static final String routeName = '/productDetails';

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}
class _ProductDetailsState extends ConsumerState<ProductDetails> {
  String? _selectedSize;
  String? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final prod = ref.watch(productDetailsProvider(widget.productId));

    return Scaffold(
      body: SingleChildScrollView(
        child: prod.when(
          data: (product) {
            return Column(
              children: [
                ProductImage(product: product),
                CustomSize(
                  product: product,
                  initial: _selectedSize,
                  onSelected: (s) => setState(() => _selectedSize = s),
                ),
                SizeColorAnd(text: "Color"),
                CustomColor(
                  product: product,
                  initial: _selectedColor,
                  onSelected: (c) => setState(() => _selectedColor = c),
                ),
                ProductMaterialAndStoreInfo(
                  storeName:
                      product.vendor?.user?.name ??
                      product.vendor?.businessName ??
                      '',
                  image:
                      product.vendor?.user?.image ??
                      "https://www.selikoff.net/blog-files/null-value.gif",
                  vendorId: product.vendor?.user?.id ?? product.vendorId,
                  onChatTap: () async {
                    final pref = await SharedPreferences.getInstance();
                    final myUserIdStr = pref.getString('user_id');
                    if (myUserIdStr == null)
                      throw Exception("User ID not found");
                    final myId = int.parse(myUserIdStr);
                    try {
                      await context.push(
                        ChatScreen.routeName,
                        extra: ChatArgs(
                          partnerId:
                              product.vendor?.user?.id ?? product.vendorId,
                          partnerName:
                              product.vendor?.user?.name ??
                              product.vendor?.businessName ??
                              '',
                          partnerImage: product.vendor?.user?.image ?? '',
                          myUserId: myId,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Chat open failed: $e')),
                      );
                    }
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Column(
                    children: const [
                      SeeMoreButton(
                        name: "Top Products",
                        seeMoreAction: null,
                        isSeeMore: false,
                      ),
                      CustomTopProducts(),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ),
      ),

      bottomNavigationBar: prod.when(
        data: (data) {
          return QuantityBuyBar(
            onBuyNow: (qty) async {
              try {
                final resp = await CartService.create(
                  productId: data.id,
                  color: _selectedColor ?? '',
                  size: _selectedSize ?? '',
                  quantity: qty,
                );

                if (!mounted) return;
                GlobalSnackbar.show(
                  context,
                  title: ("Success"),
                  message: "Added to cart",
                );
                ref.invalidate(cartProvider);

                context.push(CartScreen.routeName);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product});
  final DetailItem product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      children: [
        Stack(
          children: [
            FirstTimeShimmerImage(
              imageUrl: product.image,
              height: 350.h,
              width: 1.sw,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              child: CircleAvatar(
                backgroundColor: AllColor.white,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(Icons.arrow_back, color: AllColor.black),
                ),
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
  const CustomSize({
    super.key,
    required this.product,
    this.initial,
    this.onSelected,
  });
  final DetailItem product;
  final String? initial;
  final ValueChanged<String>? onSelected;

  @override
  State<CustomSize> createState() => _CustomSizeState();
}

class _CustomSizeState extends State<CustomSize> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      final idx = widget.product.size.indexOf(i);
      if (idx >= 0) selectedIndex = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizeColorAnd(text: "Size"),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AllColor.lightBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(product.size.length, (index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                    widget.onSelected?.call(product.size[index]);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AllColor.white : AllColor.transparent,
                      borderRadius: BorderRadius.circular(50.r),
                      border: isSelected
                          ? Border.all(color: AllColor.blue, width: 3.w)
                          : null,
                    ),
                    child: Text(
                      product.size[index],
                      style: TextStyle(
                        fontSize: isSelected ? 16.sp : 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? AllColor.blue : AllColor.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class SizeColorAnd extends StatelessWidget {
  const SizeColorAnd({super.key, required this.text});

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
  const CustomColor({
    super.key,
    required this.product,
    this.initial,
    this.onSelected,
  });
  final DetailItem product;
  final String? initial; // raw string e.g. "red" / "d926cd"
  final ValueChanged<String>? onSelected;

  @override
  State<CustomColor> createState() => _CustomColorState();
}

class _CustomColorState extends State<CustomColor> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      final idx = widget.product.color.indexOf(i);
      if (idx >= 0) selectedIndex = idx;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.product.color.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final raw = widget.product.color[index]; // e.g. "red" বা "d926cd"
          // Hex হলে সেফলি দেখাতে try করলাম; না হলে ডিফল্ট grey
          Color swatch;
          try {
            swatch = Color(int.parse('0xff${raw.replaceAll('#', '')}'));
          } catch (_) {
            swatch = Colors.grey; // named color হলে fallback
          }

          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
              widget.onSelected?.call(raw); // ✅ raw string parent-এ
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
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: swatch,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.w),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 25.sp,
                      color: Colors.white,
                      weight: 900,
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
    this.storeName = '___',
    this.rating = 4.6,
    this.reviewCount = 56,
    this.onChatTap,
    this.image =
        "https://t3.ftcdn.net/jpg/05/62/05/20/360_F_562052065_yk3KPuruq10oyfeu5jniLTS4I2ky3bYX.jpg",
    required this.vendorId,
  });

  final List<MaterialChip> materials;
  final String storeName;
  final double rating;
  final int reviewCount;
  final VoidCallback? onChatTap;
  final String image;
  final int vendorId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Materials row
          SizeColorAnd(text: "Specifications"),

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
              InkWell(
                onTap: () {
                  context.push(BuyerVendorProfileScreen.routeName, extra: vendorId);
                },
                child: CircleAvatar(
                  radius: 25,
                  // TODO: Replace with the actual vendor image URL from your product/vendor data
                  backgroundImage: NetworkImage(image),
                ),
              ),
              SizedBox(width: 20.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      context.push(BuyerVendorProfileScreen.routeName, extra: vendorId);
                    },
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

                      InkWell(
                        onTap: () {
                          context.push(ReviewScreen.routeName);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            // color: AllColor.badgeBg,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AllColor.black,
                              width: 0.8,
                            ),
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
                      SizedBox(width: 5.w),
                      Text(
                        "Chat naw",
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
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
                _QtyIcon(
                  onTap: _dec,
                  child: Text('−', style: TextStyle(fontSize: 16.sp)),
                ),
                SizedBox(width: 10.w),
                Text(
                  '$qty',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10.w),
                _QtyIcon(
                  onTap: _inc,
                  child: Text('+', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
          ),
          Spacer(),

          SizedBox(
            width: 180.w,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () => widget.onBuyNow(qty),
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