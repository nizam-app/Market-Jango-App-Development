import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/driver/screen/driver_order_details.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';

class DriverOrder extends StatefulWidget {
  const DriverOrder({super.key});
  static const routeName = "/driverOrder";

  @override
  State<DriverOrder> createState() => _DriverOrderState();
}

class _DriverOrderState extends State<DriverOrder> {
  final _search = TextEditingController();
  int _tab = 0; // 0=All, 1=Pending, 2=On the way, 3=Delivered

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _demoOrders
        .where((e) {
          switch (_tab) {
            case 1:
              return e.status == OrderStatus.pending;
            case 2:
              return e.status == OrderStatus.onTheWay;
            case 3:
              return e.status == OrderStatus.delivered;
            default:
              return true;
          }
        })
        .where(
          (e) =>
              _search.text.trim().isEmpty ||
              e.orderId.toLowerCase().contains(_search.text.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: _SearchField(
                controller: _search,
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(height: 12.h),

            // Filter chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: _FilterChips(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 6.w),
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) => _OrderCard(
                  data: items[i],
                  
                  onSeeDetails: () => context.push(
                    '${OrderDetailsScreen.routeName}?id=${items[i].orderId}',
                  ),
                 
                  onTrackOrder: items[i].status == OrderStatus.delivered
                      ? null
                      : () => context.push(
                        '${DriverTrakingScreen.routeName}?id =${items[i].orderId}',
                          
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== Models & Demo Data ===================== */

enum OrderStatus { delivered, pending, onTheWay }

class OrderItem {
  final String orderId;
  final String pickup;
  final String destination;
  final double price;
  final OrderStatus status;

  const OrderItem({
    required this.orderId,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.status,
  });
}

const _demoOrders = <OrderItem>[
  OrderItem(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.delivered,
  ),
  OrderItem(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.pending,
  ),
  OrderItem(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.onTheWay,
  ),
  OrderItem(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.pending,
  ),
  OrderItem(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.onTheWay,
  ),
];

/* ===================== Reusable Widgets ===================== */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search order',
        hintStyle: TextStyle(color: AllColor.textHintColor),
        filled: true,
        fillColor: AllColor.grey100,
        prefixIcon: Icon(Icons.search, color: AllColor.black54),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.w),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AllColor.blue500),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _FilterChips({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Pending', 'On the way', 'Delivered'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final selected = i == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onChanged(i),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 8.w),
              decoration: BoxDecoration(
                color: selected ? AllColor.loginButtomColor : AllColor.grey100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AllColor.loginButtomColor
                      : AllColor.grey200,
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: selected ? AllColor.white : AllColor.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem data;
  final VoidCallback onSeeDetails;
  final VoidCallback? onTrackOrder;

  const _OrderCard({
    required this.data,
    required this.onSeeDetails,
    this.onTrackOrder,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = "\$${data.price.toStringAsFixed(2).replaceAll('.', ',')}";

    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColor.grey200),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // status + price
          Row(
            children: [
              _StatusPill(status: data.status),
              const Spacer(),
              Text(
                priceText,
                style: TextStyle(
                  color: AllColor.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 22.sp,
                  letterSpacing: .1,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Order ID ${data.orderId}',
            style: TextStyle(
              color: AllColor.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          _kvBold('Pick up location: ', data.pickup),
          SizedBox(height: 8.h),
          _kvBold('Destination: ', data.destination),
          SizedBox(height: 14.h),

          // buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PrimaryButton(text: 'See details', onTap: onSeeDetails),
            
              if (onTrackOrder != null)
                _SecondaryButton(text: 'Track order', onTap: onTrackOrder!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvBold(String k, String v) {
    return RichText(
      text: TextSpan(
        text: k,
        style: TextStyle(color: AllColor.black, fontSize: 14.sp),
        children: [
          TextSpan(
            text: v,
            style: TextStyle(
              color: AllColor.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color border;
    late String text;
    switch (status) {
      case OrderStatus.delivered:
        border = AllColor.green500;
        text = 'Delivered';
        break;
      case OrderStatus.pending:
        border = AllColor.blue500;
        text = 'Pending';
        break;
      case OrderStatus.onTheWay:
        border = AllColor.yellow500;
        text = 'On the way';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: border.withOpacity(.10),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: border,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AllColor.loginButtomColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          text,
          style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AllColor.blue500, width: 1),
          backgroundColor: AllColor.blue500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 16.h),
        ),
        child: Text(
          text,
          style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
