import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class VendorAssignedOrder extends StatefulWidget {
  const VendorAssignedOrder({super.key});
  static const routeName = "/vendorOrderAssigned";

  @override
  State<VendorAssignedOrder> createState() => _VendorAssignedOrderState();
}

class _VendorAssignedOrderState extends State<VendorAssignedOrder> {
  final _search = TextEditingController();
  int _tab = 1; // 0=Pending, 1=Assigned order (default), 2=Completed

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _demoOrders
        .where(
          (e) => _tab == 0
              ? e.status == OrderStatus.pending
              : _tab == 1
              ? e.status == OrderStatus.assigned
              : e.status == OrderStatus.completed,
        )
        .where(
          (e) =>
              _search.text.trim().isEmpty ||
              e.orderId.toLowerCase().contains(_search.text.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomBackButton(),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: _SearchField(
                controller: _search,
                hint: 'Search you product',
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(height: 12.h),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: _Tabs(
                current: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            SizedBox(height: 12.h),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) => _AssignedSection(
                  driverName: 'MR. John doe',
                  child: _AssignedCard(
                    data: items[i],
                    onSeeDetails: () {
                      // TODO: replace with your route
                      // context.go('/vendor/orders/assigned/details?id=${items[i].orderId}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('See Details tapped')),
                      );
                    },
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

/* -------------------- Models & Demo Data -------------------- */

enum OrderStatus { pending, assigned, completed }

class AssignedOrderData {
  final String orderId;
  final String pickup;
  final String destination;
  final double price;
  final OrderStatus status;

  const AssignedOrderData({
    required this.orderId,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.status,
  });
}

const _demoOrders = <AssignedOrderData>[
  AssignedOrderData(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.assigned,
  ),
  AssignedOrderData(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.assigned,
  ),
  AssignedOrderData(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.assigned,
  ),
  AssignedOrderData(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: OrderStatus.assigned,
  ),
];

/* -------------------- UI Pieces -------------------- */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AllColor.textHintColor),
        prefixIcon: Icon(Icons.search_rounded, color: AllColor.black54),
        filled: true,
        fillColor: AllColor.grey100,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AllColor.blue500),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int current; // 0..2
  final ValueChanged<int> onChanged;
  const _Tabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String text, int index, {VoidCallback? onTap}) {
      final selected = current == index;
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap ?? () => onChanged(index), // custom tap OR default
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: selected ? AllColor.loginButtomColor : AllColor.grey100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AllColor.loginButtomColor : AllColor.grey200,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? AllColor.white : AllColor.black,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(
          'Pending',
          0,
          onTap: () {
            context.push("/vendorOrderPending");
          },
        ),
        SizedBox(width: 8.w),
        chip('Assigned order', 1),
        SizedBox(width: 8.w),
        chip(
          'Completed',
          2,
          onTap: () {
            context.push("/vendorOrderCompleted");
          },
        ),
      ],
    );
  }
}

class _AssignedSection extends StatelessWidget {
  final String driverName;
  final Widget child;
  const _AssignedSection({required this.driverName, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Driver: $driverName',
          style: TextStyle(
            color: AllColor.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _AssignedCard extends StatelessWidget {
  final AssignedOrderData data;
  final VoidCallback onSeeDetails;

  const _AssignedCard({required this.data, required this.onSeeDetails});

  @override
  Widget build(BuildContext context) {
    final priceText = "\$${data.price.toStringAsFixed(2).replaceAll('.', ',')}";

    return Container(
      decoration: BoxDecoration(
        color: AllColor.grey100.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AllColor.grey200),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // price at right
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order ID ${data.orderId}',
                    style: TextStyle(
                      color: AllColor.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  priceText,
                  style: TextStyle(
                    color: AllColor.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: .1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _kvBold('Pick up location: ', data.pickup),
            const SizedBox(height: 6),
            _kvBold('Destination: ', data.destination),
            const SizedBox(height: 14),

            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: onSeeDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  'See Details',
                  style: TextStyle(
                    color: AllColor.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvBold(String k, String v) {
    return RichText(
      text: TextSpan(
        text: k,
        style: TextStyle(color: AllColor.black, fontSize: 14),
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
