import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/custom_total_checkout_section.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_model.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/web_view_screen.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/show_shipping_contract_sheet.dart';
import 'package:market_jango/features/transport/screens/add_card_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/prement_page_data_model.dart'; // <-- PaymentPageData
import '../widget/show_shipping_address_sheet.dart';

class BuyerPaymentScreen extends ConsumerWidget {
  BuyerPaymentScreen({super.key});
  static const routeName = "/buyerPaymentScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;

    final args = GoRouterState.of(context).extra as PaymentPageData?;

    final shippingLines = args == null
        ? const ['____, ____,', '_____']
        : [
            [
              args.buyer.shipAddress ?? args.buyer.address,
              args.buyer.shipCity,
              // args.buyer.shipState ?? args.buyer.state,
              // args.buyer.postcode,
              args.buyer.shipCountry ?? args.buyer.country,
            ].where((e) => e != null && e!.trim().isNotEmpty).join(', '),
          ];

    final contactLines = args == null
        ? const ['___,', '+____,', '_____']
        : [
            (args.buyer.shipName ?? '—'),
            (args.buyer.shipPhone ?? '—'),
            (args.buyer.shipEmail ?? '—'),
          ];

    // UI items map (ডিজাইন একই, কেবল ডেটা ম্যাপ করা)
    final List<CartItem> uiItems = args == null
        ? [
            CartItem(
              title: 'Lorem ipsum dolor sit amet consectetur.',
              imageUrl: 'https://picsum.photos/seed/a/200',
              qty: 1,
              price: 17.00,
            ),
            CartItem(
              title: 'Lorem ipsum dolor sit amet consectetur.',
              imageUrl: 'https://picsum.photos/seed/b/200',
              qty: 1,
              price: 23.00,
            ),
          ]
        : args.items
              .map(
                (it) => CartItem(
                  title: it.product.name,
                  imageUrl: it.product.image,
                  qty: it.quantity,
                  price: double.tryParse(it.price) ?? 0,
                ),
              )
              .toList();

    final List<ShippingOption> options = args == null
        ? [
            ShippingOption(title: 'Delivery charge', cost: 0.00),
            ShippingOption(title: 'Own Pick up', cost: 0.0),
          ]
        : [
            ShippingOption(title: 'Delivery charge', cost: args.deliveryTotal),
            ShippingOption(title: 'Own Pick up', cost: 0.0),
          ];

    final totalForBottom = args?.grandTotal ?? 40;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                Tuppertextandbackbutton(screenName: "Payment"),
                SizedBox(height: 20.h),
                CustomAddressAnddContract(
                  title: 'Shipping Address',
                  lines: shippingLines,
                  onEdit: () {
                    showShippingAddressSheet(context, ref, args);
                  },
                ),
                SizedBox(height: 20.h),
                CustomAddressAnddContract(
                  title: 'Contact Information',
                  lines: contactLines,
                  onEdit: () {
                    showShippingContractSheet(context, ref, args);
                  },
                ),

                SizedBox(height: 20.h),
                CustomItemShow(
                  items: uiItems,
                  options: options,
                  selectedIndex: 0,
                  onShippingChanged: (i) {},
                  currency: '\$',
                ),

                // buildPaymentMethodText(theme, context),
                // SizedBox(height: 12.h),
                //
                // CustomPaymentMethod(
                //   options: paymentOptions,
                //   initialIndex: 0,
                //   onChanged: (i) {},
                // ),
              ],
            ),
          ),
        ),
      ),
      // Bottom total: args থেকে
      bottomNavigationBar: CustomTotalCheckoutSection(
        totalPrice: totalForBottom,
        context: context,
        onCheckout: () => startCheckout(context),
      ),
    );
  }

  Row buildPaymentMethodText(TextTheme theme, BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text("Payment Method", style: theme.headlineLarge)),
        AddressEditIcon(
          tiBg: AllColor.blue500,
          onEdit: () {
            context.push(AddCardScreen.routeName);
          },
        ),
      ],
    );
  }

  // Future<void> _onCheckout(BuildContext context, ref) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Dialog(
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               width: 22,
  //               height: 22,
  //               child: CircularProgressIndicator(strokeWidth: 2.4),
  //             ),
  //             SizedBox(width: 12),
  //             Text('Preparing checkout...'),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //
  //   try {
  //     final url = await fetchPaymentUrl(ref);
  //     if (context.mounted) Navigator.pop(context);
  //     if (url == null || url.isEmpty) {
  //       if (context.mounted)
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Payment URL not found')),
  //         );
  //       return;
  //     }
  //     await launchUrlString(url, mode: LaunchMode.externalApplication);
  //   } catch (e) {
  //     if (context.mounted) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
  //     }
  //   }
  // }
}

class CustomAddressAnddContract extends StatelessWidget {
  const CustomAddressAnddContract({
    super.key,
    required this.title,
    required this.lines,
    this.onEdit,
  });

  final String title;

  final List<String> lines;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final bg = AllColor.white;
    final tiBg = AllColor.blueGrey900;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(color: AllColor.grey.withOpacity(0.25)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Body lines
                  Text(
                    lines.join('\n'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black.withOpacity(0.8),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Edit button
            AddressEditIcon(tiBg: tiBg, onEdit: onEdit),
          ],
        ),
      ),
    );
  }
}

class AddressEditIcon extends StatelessWidget {
  const AddressEditIcon({super.key, required this.tiBg, required this.onEdit});

  final Color tiBg;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tiBg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(Icons.edit, color: Colors.white, size: 18.sp),
        ),
      ),
    );
  }
}

class CustomItemShow extends StatefulWidget {
  const CustomItemShow({
    super.key,
    required this.items,
    required this.options,
    this.selectedIndex = 0,
    this.onShippingChanged,
    this.currency = '\$',
    this.titleItems = 'Items',
    this.titleShipping = 'Shipping Options',
  });

  final List<CartItem> items;
  final List<ShippingOption> options;
  final int selectedIndex;
  final ValueChanged<int>? onShippingChanged;
  final String currency;
  final String titleItems;
  final String titleShipping;

  @override
  State<CustomItemShow> createState() => _CustomItemShowState();
}

class _CustomItemShowState extends State<CustomItemShow> {
  late int _selected;

  @override
  void initState() {
    _selected = widget.selectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            widget.titleItems,
            badgeText: '${widget.items.length}',
          ),
          SizedBox(height: 8.h),

          // Items (ListView.builder)
          ListView.builder(
            itemCount: widget.items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => _itemRow(widget.items[i]),
          ),
          SizedBox(height: 30.h),

          Text(widget.titleShipping, style: theme.headlineLarge),
          SizedBox(height: 20.h),

          Column(
            children: List.generate(widget.options.length, (i) {
              final op = widget.options[i];
              final selected = _selected == i;
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _shippingTile(
                  title: op.title,
                  priceLabel: op.cost == 0
                      ? 'Free'
                      : '${widget.currency}${op.cost.toStringAsFixed(2)}',
                  selected: selected,
                  onTap: () {
                    setState(() => _selected = i);
                    widget.onShippingChanged?.call(i);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required String badgeText}) {
    final theme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(title, style: theme.headlineLarge),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AllColor.blue.shade100,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemRow(CartItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          // avatar + qty badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AllColor.white,
                child: CircleAvatar(
                  radius: 26.r,
                  backgroundColor: AllColor.grey200,
                  backgroundImage: NetworkImage(item.imageUrl),
                ),
              ),
              Positioned(
                right: -2.w,
                top: -2.h,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6.r,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: const Color(0xffE5EBFC),
                    child: Text(
                      '${item.qty}',
                      style: TextStyle(
                        color: AllColor.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(width: 8.w),

          Text(
            '${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shippingTile({
    required String title,
    required String priceLabel,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              // custom radio
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.blue : Colors.blueGrey,
                    width: 2,
                  ),
                  color: selected ? Colors.blue : Colors.transparent,
                ),
                child: selected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 16.r,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                priceLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> startCheckout(BuildContext context) async {
  // লোডিং ডায়ালগ
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(width: 12),
            Text('Preparing checkout...'),
          ],
        ),
      ),
    ),
  );

  try {
    // ref ছাড়াই container নাও
    final container = ProviderScope.containerOf(context, listen: false);
    final token = await container.read(authTokenProvider.future);

    final uri = Uri.parse(
      BuyerAPIController.invoice_createate,
    ); // GET /api/invoice/create
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    // লোডার বন্ধ
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice failed: ${res.statusCode}')),
      );
      return;
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    String? paymentUrl;
    final data = body['data'];
    if (data is List && data.isNotEmpty) {
      final pm = data.first['paymentMethod'];
      if (pm is Map<String, dynamic>) {
        paymentUrl = pm['payment_url']?.toString();
      }
    }

    if (paymentUrl == null || paymentUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment URL not found')));
      return;
    }

    final u = Uri.parse(paymentUrl);
    // আগে চেক করো
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaymentWebView(url: paymentUrl!)),
      );
    }
  } catch (e) {
    // লোডার থাকলে বন্ধ করো
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
  }
}
