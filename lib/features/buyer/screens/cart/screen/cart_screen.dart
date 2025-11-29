import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/localization/translation_kay.dart';
import 'package:market_jango/core/widget/custom_total_checkout_section.dart';
import 'package:market_jango/features/buyer/screens/cart/data/cart_inc_dec_logic.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/buyer_shiping_update_logic.dart';
import 'package:market_jango/features/buyer/screens/cart/logic/cart_data.dart';
import 'package:market_jango/features/buyer/screens/cart/model/cart_model.dart';
import 'package:market_jango/features/buyer/screens/cart/screen/shiping_address_update_botton_shet.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_page_data_model.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const String routeName = '/cartScreen';

  // double _calculateTotalPriceFromApi(List<CartItem> items) {
  //   double total = 0;
  //   for (final it in items) {
  //     final price = double.tryParse(it.price) ?? 0;
  //     final qty = it.quantity;
  //     final delivery = double.tryParse(it.deliveryCharge) ?? 0;
  //     total += (price * qty) + delivery;
  //   }
  //   return total;
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: cartAsync.when(
          loading: () => Text(
            ref.t(TKeys.cart),
            style: theme.titleLarge!.copyWith(fontSize: 22.sp),
          ),
          error: (e, _) => Text(
            "Error $e",
            style: theme.titleLarge!.copyWith(fontSize: 22.sp),
          ),
          data: (item) {
            final items = item.items;
            return Row(
              children: [
                Text(
                  ref.t(TKeys.cart),
                  style: theme.titleLarge!.copyWith(fontSize: 22.sp),
                ),
                SizedBox(width: 20.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AllColor.blue200,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    items.length.toString(),
                    style: theme.titleLarge!.copyWith(fontSize: 14.sp),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: cartAsync.when(
              loading: () => _buildShippingAddress(context, null, ref),
              error: (_, __) => _buildShippingAddress(context, null, ref),
              data: (item) {
                final items = item.items;
                return _buildShippingAddress(
                  context,
                  items.isNotEmpty ? items.first.buyer : null,
                  ref,
                );
              },
            ),
          ),
          SizedBox(height: 20.h),

          // ⬇️ তালিকা
          Expanded(
            child: cartAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
              data: (dat) {
                final data = dat.items;
                if (data.isEmpty) {
                  return Center(
                    //'Please add the cart product'
                    child: Text(ref.t(TKeys.please_add_the_cart_product)),
                  );
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final allData = data[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: _buildCartItemCard(allData, context, ref),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ Checkout এ ক্লিক করলে PaymentPageData পাঠাও
          cartAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (items) => CustomTotalCheckoutSection(
              totalPrice: items.total,
              context: context,
              onCheckout: () {
                final pd = _buildPaymentData(items.items, items.total);
                context.push(BuyerPaymentScreen.routeName, extra: pd);
              },
            ),
          ),
        ],
      ),
    );
  }

  PaymentPageData _buildPaymentData(List<CartItem> items, double total) {
    double subtotal = 0, delivery = 0;
    for (final it in items) {
      final p = double.tryParse(it.price) ?? 0;
      final d = double.tryParse(it.deliveryCharge) ?? 0;
      subtotal += p * it.quantity;
      delivery += d;
    }
    final buyer = items.first.buyer;
    return PaymentPageData(
      buyer: buyer,
      items: items,
      subtotal: subtotal,
      deliveryTotal: delivery,
      grandTotal: total,
    );
  }

  Widget _buildCartItemCard(CartItem item, BuildContext context, ref) {
    final theme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AllColor.black.withOpacity(0.005),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image + delete
            Padding(
              padding: EdgeInsets.only(left: 7.w),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      item.product.image,
                      width: 90.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90.w,
                          height: 100.h,
                          color: AllColor.grey,
                          child: Icon(
                            Icons.broken_image,
                            color: AllColor.blue,
                            size: 40.sp,
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(2.r),
                    padding: EdgeInsets.all(5.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete,
                      color: AllColor.orange,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    item.product.name,
                    style: theme.titleMedium!.copyWith(color: AllColor.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Color: ${item.color}  •  Size: ${item.size}',
                    style: TextStyle(color: AllColor.black, fontSize: 11.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AllColor.black, fontSize: 11.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${item.price}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Quantity
            _buildQuantityControl(item, ref),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item, WidgetRef ref) {
    // এখন কোন কোন প্রোডাক্ট আপডেট হচ্ছে সেটি দেখবো
    final updatingIds = ref.watch(cartUpdatingIdsProvider);
    final isUpdating = updatingIds.contains(item.productId);

    Future<void> _change(CartAction action) async {
      final updater = ref.read(cartUpdatingIdsProvider.notifier);

      // id টা সেটে যোগ করলাম -> UI তে loader দেখাবে
      updater.update((s) => {...s, item.productId});

      try {
        if (action == CartAction.decrease && item.quantity <= 1) {
          // চাইলে এখানে remove confirm করতে পারেন
        }
        await ref
            .read(cartServiceProvider)
            .updateQuantity(productId: item.productId, action: action);

        // ডেটা রিফ্রেশ
        ref.invalidate(cartProvider);
      } catch (e) {
        ScaffoldMessenger.of(
          ref.context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      } finally {
        // কাজ শেষ -> id সরিয়ে দিন, loader বন্ধ
        updater.update((s) {
          final ns = {...s};
          ns.remove(item.productId);
          return ns;
        });
      }
    }

    if (isUpdating) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // হালকা ব্লু
          border: Border.all(color: const Color(0xFFD0E2FF)),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16.r,
              height: 16.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8.w),
            // 'Updating...'
            Text(
              ref.t(TKeys.updating),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    // 👉 নরমাল স্টেট
    return Row(
      children: [
        _circleButton(Icons.remove, () => _change(CartAction.decrease)),
        SizedBox(width: 8.w),
        Text(
          '${item.quantity}',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 8.w),
        _circleButton(Icons.add, () => _change(CartAction.increase)),
      ],
    );
  }

  Widget _circleButton(
    IconData icon,
    VoidCallback onTap, {
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AllColor.black.withOpacity(0.8)),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: disabled ? AllColor.grey : AllColor.black,
        ),
      ),
    );
  }

  // Widget _circleButton(IconData icon, VoidCallback onTap) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       padding: EdgeInsets.all(4.r),
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         border: Border.all(color: AllColor.black.withOpacity(0.8)),
  //       ),
  //       child: Icon(icon, size: 16.sp, color: AllColor.black),
  //     ),
  //   );
  // }

  Widget _buildShippingAddress(BuildContext context, Buyer? buyer, ref) {
    final theme = Theme.of(context).textTheme;
    final addressLine = [
      buyer?.shipAddress ?? buyer?.address,
      buyer?.shipCity,
      // buyer?.shipState ?? buyer?.state,
      // buyer?.postcode,
      buyer?.shipCountry ?? buyer?.country,
    ].where((e) => e != null && e!.trim().isNotEmpty).join(', ');

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AllColor.grey100,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //'Shipping Address'
                Text(
                  "Shipping Address",
                  style: theme.titleLarge?.copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  addressLine.isEmpty ? '—' : addressLine,
                  style: TextStyle(color: AllColor.black, fontSize: 11.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (buyer?.location != null &&
                    buyer!.location!.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'Location: ${buyer.location}',
                      style: TextStyle(color: AllColor.black, fontSize: 11.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          InkWell(
            onTap: () {
              showShippingAddressBottomSheet(context, ref, buyer: buyer);
            },
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AllColor.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AllColor.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

