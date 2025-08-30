import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/custom_total_checkout_section.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_model.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/custom_payment_method.dart';

import '../widget/show_shipping_address_sheet.dart';

class BuyerPaymentScreen extends ConsumerWidget {
   BuyerPaymentScreen({super.key});
  static const routeName = "/buyerPaymentScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body:SafeArea(
          child:
          SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                     Tuppertextandbackbutton(screenName: "Payment")  ,
              CustomAddressAnddContract(
                title: 'Shipping Address',
                lines: const [
                  '56 Clerkenwell Road, London EC1M 5PX,',
                  'United Kingdom',
                ],
                onEdit: () {
                  showShippingAddressSheet(context);
                },
              ),
              CustomAddressAnddContract(
                title: 'Contact Information',
                lines: const [
                  'MTS UK Office,',
                  '+44 20 7946 0123,',
                  'example@gmail.com',
                ],
                onEdit: () {
                  showShippingAddressSheet(context);
                },) ,
            
                  CustomItemShow(
                    items: items,
                    options: options,
                    selectedIndex: 0,
                    onShippingChanged: (i) {
                      // handle shipping selected
                    },
                    currency: '\$',
                  ),
                  buildPaymentMethodText(theme),
                  SizedBox(height: 12.h),
                  CustomPaymentMethod(
                    options: paymentOptions,
                    initialIndex: 0,
                    onChanged: (i) {
                      // handle selected method index
                    },
                  ) ,
                 
                ],
                  ),
            ),
          )
      ),
      bottomNavigationBar:  CustomTotalCheckoutSection(totalPrice: 40, context: context),
    );
  }

  Row buildPaymentMethodText(TextTheme theme) {
    return Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Payment Method",
                        style: theme.headlineLarge,

                      ),
                    ),
                    AddressEditIcon(tiBg: AllColor.blue500, onEdit: (){})
                    ,
                   
                  ],
                );
  }
  final items = [
    CartItem(title: 'Lorem ipsum dolor sit amet consectetur.', imageUrl: 'https://picsum.photos/seed/a/200', qty: 1, price: 17.00),
    CartItem(title: 'Lorem ipsum dolor sit amet consectetur.', imageUrl: 'https://picsum.photos/seed/b/200', qty: 1, price: 23.00),
  ];

  final options = [
    ShippingOption(title: 'Delivery charge', cost: 5.00),
    ShippingOption(title: 'Own Pick up', cost: 0.0),
  ];
   final paymentOptions = [
     PaymentOption(label: 'Card', icon: Icons.credit_card),
     PaymentOption(label: 'G Pay', asset: 'assets/icon/google.jpg'),
     PaymentOption(label: 'PayPal', asset: 'assets/icon/paypal.png'),
     PaymentOption(label: 'Cash', icon: Icons.attach_money),
   ];

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
    final bg =  AllColor.white;
    final tiBg =  AllColor.blueGrey900;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h,),
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
  const AddressEditIcon({
    super.key,
    required this.tiBg,
    required this.onEdit,
  });

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
  final theme =  Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(widget.titleItems, badgeText: '${widget.items.length}'),
          SizedBox(height: 8.h),

          // Items (ListView.builder)
          ListView.builder(
            itemCount: widget.items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => _itemRow(widget.items[i]),
          ),
          SizedBox(height: 18.h),

          Text(
            widget.titleShipping,
            style:theme.headlineLarge,
          ),
          SizedBox(height: 12.h),

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

  // ---------- Parts ----------
  Widget _sectionHeader(String title, {required String badgeText}) {
   final theme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(title,
            style:theme.headlineLarge ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AllColor.blue.shade100,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(badgeText,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp, color: Colors.black87)),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6.r)],
                  ),
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: Color(0xffE5EBFC),
                    child: Text('${item.qty}',
                        style: TextStyle(
                            color: AllColor.black, fontSize: 12.sp, fontWeight: FontWeight.w700)),
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
              style: Theme.of(context).textTheme.titleMedium),
            ),
        
          SizedBox(width: 8.w),

          Text(
            '${item.price.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87),
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
                  border: Border.all(color: selected ? Colors.blue : Colors.blueGrey, width: 2),
                  color: selected ? Colors.blue : Colors.transparent,
                ),
                child: selected
                    ? Center(child: Icon(Icons.check, size: 16.r, color: Colors.white))
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
              ),
              Text(priceLabel,
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}