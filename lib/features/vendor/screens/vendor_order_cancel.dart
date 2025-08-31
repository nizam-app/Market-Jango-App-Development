

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class VendorOrderCancel extends StatefulWidget {
  const VendorOrderCancel({super.key});
  static const routeName = "/vendorOrderCancel";

  @override
  State<VendorOrderCancel> createState() => _VendorOrderCancelState();
}

class _VendorOrderCancelState extends State<VendorOrderCancel> {
  final _search = TextEditingController();
  int _tab = 2; 
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _demoOrders
        .where((e) =>
            _search.text.trim().isEmpty ||
            e.orderNo.toLowerCase().contains(_search.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AllColor.white,
      
      body: SafeArea(

        child: Column(
          children: [
            CustomBackButton(), 
            SizedBox(height: 20.h,),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.h),
              child: _SearchField(
                controller: _search,
                hint: 'Seach you product',
                onChanged: (_) => setState(() {}),
              ),
            ),
             SizedBox(height: 12.h),

            // Tabs
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.h),
              child: _Tabs(
                current: _tab,
                onChanged: (i) {
                  setState(() => _tab = i);
                  // ← hook your navigation here if you split tabs across routes
                },
              ),
            ),
             SizedBox(height: 12.h),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _OrderCard(data: items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== Models & Demo Data ===================== */

class OrderData {
  final String orderNo;
  final String title;
  final String customer;
  final String phone;
  final int qty;
  final String date;
  final double price;
  final String imageUrl;

  const OrderData({
    required this.orderNo,
    required this.title,
    required this.customer,
    required this.phone,
    required this.qty,
    required this.date,
    required this.price,
    required this.imageUrl,
  });
}

const _demoOrders = <OrderData>[
  OrderData(
    orderNo: '12345',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    phone: '+00123456789',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600',
  ),
  OrderData(
    orderNo: '12345',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    phone: '+00123456789',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
  ),
  OrderData(
    orderNo: '12345',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    phone: '+00123456789',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
  ),
];

/* ===================== UI Pieces ===================== */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.controller, required this.hint, this.onChanged});

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
        contentPadding:  EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.w),
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
    Widget chip(String text, int index) {
      final selected = current == index;
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(index),
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: 14.h, vertical: 9.w),
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
              fontSize: 13.sp,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Assigned order', 0),
         SizedBox(width: 8.w),
        chip('Completed', 1),
         SizedBox(width: 8.w),
        chip('Canceled', 2),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderData data;
  const _OrderCard({required this.data});

  @override
  Widget build(BuildContext context) {
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
          // Top row: order # and red "Cancel" pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${data.orderNo}',
                  style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w700)),
           
              _CancelPill(),
            ],
          ),
           SizedBox(height: 10.h),
          // Middle: image + info + price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 64,
                  width: 64,
                  color: AllColor.grey100,
                  child: Image.network(data.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title,
                        style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('John doe',
                        style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w700)),
                    Text('+00123456789', style: TextStyle(color: AllColor.black54)),
                  ],
                ),
              ),
               SizedBox(width: 8.w),
             
            ],
          ),

           SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Qty: ${data.qty}', style: TextStyle(color: AllColor.black54)),
               Text('\$${data.price.toStringAsFixed(0)}',
                  style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
           SizedBox(height: 6.h),
          Text('Order placed on ${data.date}',
              style: TextStyle(color: AllColor.black54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CancelPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color c = Colors.redAccent;
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.w),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Cancel',
          style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

