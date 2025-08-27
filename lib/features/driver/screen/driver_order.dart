import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
class DriverOrder extends StatefulWidget {
  const DriverOrder({super.key});
  static final routeName ="/driverOrder"; 

  @override
  State<DriverOrder> createState() => _DriverOrderState();
}

class _DriverOrderState extends State<DriverOrder> {
  String _query = "";
  _Tab _selected = _Tab.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: SafeArea(
        child: Column(
          children: [
            _SearchBox(
              hint: "Search order",
              value: _query,
              onChanged: (v) => setState(() => _query = v),
            ),
            _FilterTabs(
              selected: _selected,
              onSelect: (t) => setState(() => _selected = t),
            ),
            _OrdersList(search: _query, tab: _selected),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ Custom Codebase ------------------------------ */


class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.hint,
    required this.value,
    required this.onChanged,
  });
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 8.h),
      child: TextField(
        onChanged: onChanged,
        controller: TextEditingController(text: value)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: value.length),
          ),
        style: TextStyle(fontSize: 14.sp, color: AllColor.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AllColor.black54, fontSize: 13.sp),
          prefixIcon: Icon(Icons.search, color: AllColor.black54, size: 20.sp),
          filled: true,
          fillColor: AllColor.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AllColor.grey200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AllColor.grey200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AllColor.blue500, width: 1),
          ),
        ),
      ),
    );
  }
}

enum _Tab { all, pending, onTheWay, delivered }

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onSelect});
  final _Tab selected;
  final ValueChanged<_Tab> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (_Tab.all, "All"),
      (_Tab.pending, "Pending"),
      (_Tab.onTheWay, "On the way"),
      (_Tab.delivered, "Delivered"),
    ];
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        itemBuilder: (_, i) {
          final (tab, label) = items[i];
          final bool isSelected = tab == selected;
          return InkWell(
            onTap: () => onSelect(tab),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AllColor.yellow500 : AllColor.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AllColor.yellow500 : AllColor.grey200,
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AllColor.white : AllColor.black87,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: items.length,
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.search, required this.tab});
  final String search;
  final _Tab tab;

  @override
  Widget build(BuildContext context) {
    final data = _OrdersListData.list.where((o) {
      final q = search.trim().toLowerCase();
      final matchQ = q.isEmpty ||
          o.id.toLowerCase().contains(q) ||
          o.pickup.toLowerCase().contains(q) ||
          o.destination.toLowerCase().contains(q);
      final matchTab = switch (tab) {
        _Tab.all => true,
        _Tab.pending => o.state == _State.pending,
        _Tab.onTheWay => o.state == _State.onTheWay,
        _Tab.delivered => o.state == _State.delivered,
      };
      return matchQ && matchTab;
    }).toList();

    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        itemBuilder: (_, i) => _OrderCard(order: data[i]),
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemCount: data.length,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _OrderModel order;

  @override
  Widget build(BuildContext context) {
    final pill = _pillStyle(order.state);
    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(.06),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusPill(
                    text: order.state.label,
                    bg: pill.bg,
                    border: pill.border,
                    fg: pill.fg,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Order ID ${order.id}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColor.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _KVRow(k: "Pick up location:", v: order.pickup, boldValue: true),
                  SizedBox(height: 4.h),
                  _KVRow(k: "Destination:", v: order.destination, boldValue: true),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FilledBtn(
                        label: "See details",
                        onTap: () {}, // TODO
                        bg: AllColor.loginButtomColor,
                        fg: AllColor.white,
                      ),
                      SizedBox(width: 10.w),
                      _OutlineBtn(
                        label: "Track order",
                        onTap: () {}, // TODO
                        border: AllColor.blue500,
                        text: AllColor.blue500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right price
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 6.h),
                Text(
                  _formatPrice(order.price),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.k, required this.v, this.boldValue = false});
  final String k;
  final String v;
  final bool boldValue;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "$k ",
        style: TextStyle(fontSize: 12.sp, color: AllColor.black54),
        children: [
          TextSpan(
            text: v,
            style: TextStyle(
              fontSize: 12.sp,
              color: AllColor.black,
              fontWeight: boldValue ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.bg,
    required this.border,
    required this.fg,
  });

  final String text;
  final Color bg;
  final Color border;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.sp, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  const _FilledBtn({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.fg,
  });
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10.r)),
        child: Text(label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12.sp)),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({
    required this.label,
    required this.onTap,
    required this.border,
    required this.text,
  });
  final String label;
  final VoidCallback onTap;
  final Color border;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(label,
            style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 12.sp)),
      ),
    );
  }
}

/* ------------------------------ Data / Helpers ------------------------------ */

enum _State { accepted, pending, onTheWay, delivered }

extension on _State {
  String get label => switch (this) {
        _State.accepted => "Accepted",
        _State.pending => "Pending",
        _State.onTheWay => "On the way",
        _State.delivered => "Delivered",
      };
}

({Color bg, Color border, Color fg}) _pillStyle(_State s) {
  switch (s) {
    case _State.accepted:
      return (bg: AllColor.yellow50, border: AllColor.yellow500, fg: AllColor.yellow700);
    case _State.pending:
      return (bg: AllColor.blue50, border: AllColor.blue500, fg: AllColor.blue500);
    case _State.onTheWay:
      return (bg: AllColor.dropDown, border: AllColor.blue200, fg: AllColor.blue900);
    case _State.delivered:
      return (bg: AllColor.grey100, border: AllColor.grey300, fg: AllColor.black54);
  }
}

class _OrderModel {
  final String id;
  final String pickup;
  final String destination;
  final double price;
  final _State state;

  _OrderModel({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.state,
  });
}

class _OrdersListData {
  static final list = <_OrderModel>[
    _OrderModel(
      id: "ORD12345",
      pickup: "Urban tech store",
      destination: "Alex Hossain",
      price: 750,
      state: _State.accepted,
    ),
    _OrderModel(
      id: "ORD12346",
      pickup: "Urban tech store",
      destination: "Alex Hossain",
      price: 750,
      state: _State.pending,
    ),
    _OrderModel(
      id: "ORD12347",
      pickup: "Urban tech store",
      destination: "Alex Hossain",
      price: 750,
      state: _State.pending,
    ),
    _OrderModel(
      id: "ORD12348",
      pickup: "Urban tech store",
      destination: "Alex Hossain",
      price: 750,
      state: _State.pending,
    ),
    _OrderModel(
      id: "ORD12349",
      pickup: "Urban tech store",
      destination: "Alex Hossain",
      price: 750,
      state: _State.accepted,
    ),
  ];
}

String _formatPrice(double v) => "\$${v.toStringAsFixed(2)}";
