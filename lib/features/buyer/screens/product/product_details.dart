import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/buyer/screens/buyer_home_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/cart_screen.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';

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
  /// ✅ only attributes selection (no size/color state anymore)
  final Map<String, String> _selectedAttrs = {};

  void _initializeSelections(DetailItem product) {
    final attrs = product.attributesMap;
    if (attrs.isEmpty) return;

    bool changed = false;
    attrs.forEach((key, values) {
      if (values.isNotEmpty && !_selectedAttrs.containsKey(key)) {
        _selectedAttrs[key] = values.first;
        changed = true;
      }
    });

    if (changed && mounted) setState(() {});
  }

  void _showOutOfStockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: AllColor.red, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AllColor.black,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Sorry, this product is currently out of stock. Please check back later.',
            style: TextStyle(fontSize: 14.sp, color: AllColor.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AllColor.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInsufficientStockDialog(BuildContext context, int availableStock) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AllColor.orange,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Insufficient Stock',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AllColor.black,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Only $availableStock item(s) available in stock. Please adjust your quantity.',
            style: TextStyle(fontSize: 14.sp, color: AllColor.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AllColor.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prod = ref.watch(productDetailsProvider(widget.productId));

    return Scaffold(
      body: SingleChildScrollView(
        child: prod.when(
          data: (product) {
            _initializeSelections(product);

            final attrs = product.attributesMap;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(product: product),
                ProductTitleAndDescription(product: product),

                /// ✅ ONLY attributes show (no size/color widgets)
                if (attrs.isNotEmpty)
                  ProductAttributesSelector(
                    attributes: attrs,
                    selected: _selectedAttrs,
                    onSelected: (key, value) {
                      setState(() => _selectedAttrs[key] = value);
                    },
                  ),

                ProductMaterialAndStoreInfo(
                  product: product,
                  userId: product.vendor.userId,
                  storeName:
                      product.vendor.user.name ??
                      product.vendor.businessName ??
                      '',
                  image:
                      (product.vendor.user.image != null &&
                          product.vendor.user.image.isNotEmpty)
                      ? product.vendor.user.image
                      : "https://www.selikoff.net/blog-files/null-value.gif",
                  vendorId: product.vendor.id,
                  rating: product.vendor.avgRating,
                  reviewCount: product.vendor.reviews.length,
                  onChatTap: () async {
                    final authStorage = AuthLocalStorage();
                    final myUserIdStr = await authStorage.getUserId();
                    if (myUserIdStr == null || myUserIdStr.isEmpty) {
                      throw Exception("User ID not found");
                    }
                    final myId = int.tryParse(myUserIdStr);
                    if (myId == null) {
                      throw Exception("Invalid user ID");
                    }
                    try {
                      await context.push(
                        GlobalChatScreen.routeName,
                        extra: ChatArgs(
                          partnerId: product.vendor.user.id ?? product.vendorId,
                          partnerName:
                              product.vendor.user.name ??
                              product.vendor.businessName ??
                              '',
                          partnerImage: product.vendor.user.image ?? '',
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

                // Just For You – no extra gap, title tight to grid
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 18.r,
                            color: AllColor.orange500,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            ref.t(BKeys.justForYou),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AllColor.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    
                      JustForYouProduct(),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: Text('Loading...')),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ),
      ),

      bottomNavigationBar: prod.when(
        data: (data) {
          return QuantityBuyBar(
            onBuyNow: (qty) async {
              // ✅ stock checks
              final stock = data.stock ?? 0;
              if (stock <= 0) {
                if (!mounted) return;
                _showOutOfStockDialog(context);
                return;
              }
              if (qty > stock) {
                if (!mounted) return;
                _showInsufficientStockDialog(context, stock);
                return;
              }

              // ✅ Ensure default selections exist
              _initializeSelections(data);

              // ✅ Validate attributes (if exists)
              final attrs = data.attributesMap;
              if (attrs.isNotEmpty) {
                for (final key in attrs.keys) {
                  final v = (_selectedAttrs[key] ?? '').trim();
                  if (v.isEmpty) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select $key')),
                    );
                    return;
                  }
                }
              }

              try {
                // ✅ Send ONLY attributes
                await CartService.create(
                  productId: data.id,
                  quantity: qty,
                  attributes: _selectedAttrs,
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
        loading: () => const Center(child: Text('Loading...')),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

/// ------------------ ProductImage (UNCHANGED) ------------------

class ProductImage extends StatefulWidget {
  const ProductImage({super.key, required this.product});
  final DetailItem product;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  List<String> get _allImages {
    final List<String> images = [];

    bool isValidImageUrl(String? url) {
      if (url == null || url.isEmpty || url.trim().isEmpty) return false;
      final trimmed = url.trim();
      return trimmed.startsWith('http://') ||
          trimmed.startsWith('https://') ||
          trimmed.startsWith('data:image');
    }

    if (isValidImageUrl(widget.product.image)) {
      images.add(widget.product.image.trim());
    }

    if (widget.product.images.isNotEmpty) {
      for (final img in widget.product.images) {
        if (isValidImageUrl(img.imagePath)) {
          images.add(img.imagePath.trim());
        }
      }
    }

    return images;
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 400.h,
        color: AllColor.grey100,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 400.h,
              color: AllColor.grey200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 60.sp,
                    color: AllColor.grey,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Image not available',
                    style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40.h,
              left: 16.w,
              child: Container(
                decoration: BoxDecoration(
                  color: AllColor.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AllColor.black.withOpacity(0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AllColor.black,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.all(8.w),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 400.h,
      color: AllColor.grey100,
      child: Stack(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: images.length,
            itemBuilder: (context, index, realIndex) {
              final imageUrl = images[index];
              return Container(
                width: double.infinity,
                color: AllColor.grey100,
                child: ClipRect(
                  child: FirstTimeShimmerImage(
                    imageUrl: imageUrl,
                    height: 400.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 400.h,
              viewportFraction: 1.0,
              autoPlay: images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInOutCubic,
              enlargeCenterPage: false,
              enableInfiniteScroll: images.length > 1,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
          Positioned(
            top: 40.h,
            left: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: AllColor.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AllColor.black.withOpacity(0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AllColor.black,
                  size: 20.sp,
                ),
                padding: EdgeInsets.all(8.w),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AllColor.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _currentIndex == index ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: _currentIndex == index
                            ? AllColor.white
                            : AllColor.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              top: 40.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AllColor.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${images.length}',
                  style: TextStyle(
                    color: AllColor.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ------------------ ProductTitleAndDescription (UNCHANGED) ------------------

class ProductTitleAndDescription extends StatelessWidget {
  const ProductTitleAndDescription({super.key, required this.product});
  final DetailItem product;

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final stock = product.stock ?? 0;
    final hasStock = stock > 0;

    return Container(
      color: AllColor.white,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _capitalizeFirst(product.name),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AllColor.black,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: hasStock
                      ? AllColor.green.withOpacity(0.1)
                      : AllColor.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: hasStock
                        ? AllColor.green.withOpacity(0.3)
                        : AllColor.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasStock ? Icons.check_circle : Icons.cancel,
                      size: 14.sp,
                      color: hasStock ? AllColor.green : AllColor.red,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      hasStock ? '$stock in stock' : 'Not in stock',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: hasStock ? AllColor.green : AllColor.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Builder(
            builder: (context) {
              final regularPrice =
                  product.regularPrice.isFinite && product.regularPrice > 0
                  ? product.regularPrice
                  : 0.0;
              final sellPrice =
                  product.sellPrice.isFinite && product.sellPrice > 0
                  ? product.sellPrice
                  : regularPrice;
              final hasDiscount =
                  regularPrice > sellPrice && sellPrice > 0 && regularPrice > 0;

              String formatPrice(double price) {
                if (!price.isFinite || price <= 0) return '0.00';
                final formatted = price.toStringAsFixed(2);
                final parts = formatted.split('.');
                final integerPart = parts[0];
                final decimalPart = parts.length > 1 ? parts[1] : '00';
                final integerWithCommas = integerPart.replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );
                return '$integerWithCommas.$decimalPart';
              }

              int calculateDiscount() {
                if (!hasDiscount) return 0;
                if (regularPrice <= 0) return 0;
                final discount =
                    ((regularPrice - sellPrice) / regularPrice * 100).round();
                return discount > 0 ? discount : 0;
              }

              return Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '\$${formatPrice(sellPrice)}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AllColor.orange,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                  if (hasDiscount) ...[
                    Text(
                      '\$${formatPrice(regularPrice)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AllColor.grey500,
                        decoration: TextDecoration.lineThrough,
                        decorationThickness: 2,
                        decorationColor: AllColor.grey500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AllColor.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: AllColor.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '-${calculateDiscount()}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          if (product.description.isNotEmpty)
            Text(
              product.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: AllColor.black87,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
/// ✅ Dynamic Attributes UI (same design style)
/// ------------------------------------------------------

class ProductAttributesSelector extends StatelessWidget {
  const ProductAttributesSelector({
    super.key,
    required this.attributes,
    required this.selected,
    required this.onSelected,
  });

  final Map<String, List<String>> attributes;
  final Map<String, String> selected;
  final void Function(String key, String value) onSelected;

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final entries = attributes.entries.toList();

    // order: color, size, then others (UI consistent)
    entries.sort((a, b) {
      int rank(String k) {
        if (k.toLowerCase() == 'color') return 0;
        if (k.toLowerCase() == 'size') return 1;
        return 2;
      }

      final ra = rank(a.key.toLowerCase());
      final rb = rank(b.key.toLowerCase());
      if (ra != rb) return ra.compareTo(rb);
      return a.key.compareTo(b.key);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.map((e) {
        final key = e.key;
        final options = e.value;
        if (options.isEmpty) return const SizedBox.shrink();

        final current = selected[key] ?? options.first;

        // Same UI pattern:
        // - size: capsule row like old CustomSize
        // - color + others: chip wrap like old CustomColor
        if (key.toLowerCase() == 'size') {
          return _SizeStyle(
            title: _cap(key),
            options: options,
            selectedValue: current,
            onTap: (v) => onSelected(key, v),
          );
        }

        return _ChipStyle(
          title: _cap(key),
          options: options,
          selectedValue: current,
          onTap: (v) => onSelected(key, v),
          isColorKey: key.toLowerCase() == 'color',
        );
      }).toList(),
    );
  }
}

class _SizeStyle extends StatelessWidget {
  const _SizeStyle({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onTap,
  });

  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizeColorAnd(text: title),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AllColor.lightBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: options.map((v) {
                final isSelected = v == selectedValue;
                return GestureDetector(
                  onTap: () => onTap(v),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AllColor.white : AllColor.transparent,
                      borderRadius: BorderRadius.circular(50.r),
                      border: isSelected
                          ? Border.all(color: AllColor.blue, width: 3.w)
                          : null,
                    ),
                    child: Text(
                      v,
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
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipStyle extends StatelessWidget {
  const _ChipStyle({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onTap,
    required this.isColorKey,
  });

  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onTap;
  final bool isColorKey;

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizeColorAnd(text: title),
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: options.map((v) {
              final isSelected = v == selectedValue;

              // color key: keep your previous blue chip style
              final bg = isSelected
                  ? AllColor.blue
                  : (isColorKey ? AllColor.blue50 : AllColor.grey100);

              final border = isSelected
                  ? AllColor.blue
                  : AllColor.blue.withOpacity(isColorKey ? 0.3 : 0.15);

              final textColor = isSelected
                  ? Colors.white
                  : (isColorKey ? AllColor.blue : AllColor.black);

              return GestureDetector(
                onTap: () => onTap(v),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: border,
                      width: isSelected ? 2.w : 1.w,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AllColor.blue.withOpacity(0.35),
                              blurRadius: 10.r,
                              offset: Offset(0, 3.h),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    isColorKey ? _cap(v) : v,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SizeColorAnd extends StatelessWidget {
  const SizeColorAnd({super.key, required this.text});
  final String text;

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Text(
            _capitalizeFirst(text),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AllColor.black,
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

/// ------------------ ProductMaterialAndStoreInfo (YOUR EXISTING) ------------------
/// আপনার আগের কোড 그대로 রাখুন (আপনি যে কোড দিয়েছেন সেটা 그대로 use করবেন)
/// নিচে class শুধু placeholder, আপনার ফাইলে already আছে।

class ProductMaterialAndStoreInfo extends ConsumerWidget {
  const ProductMaterialAndStoreInfo({
    super.key,
    required this.product,
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
    required this.userId,
  });

  final DetailItem product;
  final List<MaterialChip> materials;
  final String storeName;
  final double rating;
  final int reviewCount;
  final VoidCallback? onChatTap;
  final String image;
  final int vendorId;
  final int userId;

  bool _isOnline(DetailItem product) {
    final user = product.vendor.user;
    final now = DateTime.now();

    if (user.isOnline) {
      return true;
    } else if (user.lastActiveAt != null) {
      final diff = now.difference(user.lastActiveAt!);
      return diff.inMinutes <= 5;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = _isOnline(product);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizeColorAnd(text: ref.t(BKeys.specifications)),

          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: materials
                .map((m) => _MaterialPill(text: m.text))
                .toList(),
          ),
          SizedBox(height: 10.h),

          // Vendor card
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            elevation: 0,
            child: InkWell(
              onTap: () {
                context.push(
                  BuyerVendorProfileScreen.routeName,
                  extra: {'vendorId': vendorId, 'userId': userId},
                );
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile image with ring and online indicator
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: FirstTimeShimmerImage(
                                imageUrl: image,
                                width: 52.r,
                                height: 52.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? Colors.green.shade500
                                  : Colors.grey.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 14.w),
                    // Name, rating, reviews
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            storeName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AllColor.black,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16.r,
                                color: Colors.amber.shade600,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AllColor.black,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              InkWell(
                                onTap: () {
                                  context.push(
                                    ReviewScreen.routeName,
                                    extra: vendorId,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '$reviewCount reviews',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Chat Now button
                    Material(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      child: InkWell(
                        onTap: onChatTap,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18.r,
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                ref.t(BKeys.chatNow),
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialPill extends ConsumerWidget {
  const _MaterialPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context, ref) {
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

class MaterialChip {
  final String text;
  const MaterialChip({required this.text});
}

/// ------------------ QuantityBuyBar (UNCHANGED) ------------------

class QuantityBuyBar extends ConsumerStatefulWidget {
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
  ConsumerState<QuantityBuyBar> createState() => _QuantityBuyBarState();
}

class _QuantityBuyBarState extends ConsumerState<QuantityBuyBar> {
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
          const Spacer(),
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
                ref.t(BKeys.buyNow),
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
