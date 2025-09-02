import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

/* ============================ MODEL ============================ */

enum OrderStatus { pending, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get title => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };
}

class ShipmentItem {
  final String orderNo;
  final String title;
  final String customer;
  final String address;
  final int qty;
  final String date;
  final double price;
  final String imageUrl;
  final OrderStatus status;

  const ShipmentItem({
    required this.orderNo,
    required this.title,
    required this.customer,
    required this.address,
    required this.qty,
    required this.date,
    required this.price,
    required this.imageUrl,
    required this.status,
  });

  factory ShipmentItem.fromJson(Map<String, dynamic> j) => ShipmentItem(
        orderNo: j['orderNo'],
        title: j['title'],
        customer: j['customer'],
        address: j['address'],
        qty: j['qty'],
        date: j['date'],
        price: (j['price'] as num).toDouble(),
        imageUrl: j['imageUrl'],
        status: OrderStatus.values[j['status']],
      );

  Map<String, dynamic> toJson() => {
        'orderNo': orderNo,
        'title': title,
        'customer': customer,
        'address': address,
        'qty': qty,
        'date': date,
        'price': price,
        'imageUrl': imageUrl,
        'status': status.index,
      };
}

/* ========================== CONTROLLER ========================= */

class ShipmentsController extends ChangeNotifier {
  int segment = 1; // 0=Request transport, 1=Track shipments
  OrderStatus status = OrderStatus.pending;
  String query = '';
  int? selectedIndex;

  final List<ShipmentItem> _items = [];
  List<ShipmentItem> get allItems => List.unmodifiable(_items);

  List<ShipmentItem> get filtered {
    final q = query.trim().toLowerCase();
    return _items
        .where((e) => e.status == status)
        .where((e) =>
            q.isEmpty ||
            e.title.toLowerCase().contains(q) ||
            e.customer.toLowerCase().contains(q) ||
            e.orderNo.toLowerCase().contains(q))
        .toList();
  }

  void setItems(List<ShipmentItem> items) {
    _items
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void setStatus(OrderStatus s) {
    if (status == s) return;
    status = s;
    selectedIndex = null;
    notifyListeners();
  }

  void setSegment(int v) {
    if (segment == v) return;
    segment = v;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void selectIndex(int i) {
    selectedIndex = i;
    notifyListeners();
  }
}

/* ============================== SCREEN ============================== */

class VendorShipmentsScreen extends StatefulWidget {
  const VendorShipmentsScreen({
    super.key,
    this.initialTab = OrderStatus.pending,
    this.initialItems,
  });

  static const routeName = "/vendortrack_shipments";

  final OrderStatus initialTab;
  final List<ShipmentItem>? initialItems;

  @override
  State<VendorShipmentsScreen> createState() => _VendorShipmentsScreenState();
}

class _VendorShipmentsScreenState extends State<VendorShipmentsScreen> {
  late final ShipmentsController controller;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ShipmentsController()..status = widget.initialTab;
    controller.setItems(widget.initialItems ?? _demoItems);
  }

  @override
  void dispose() {
    _search.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final items = controller.filtered;

        return Scaffold(
          backgroundColor: AllColor.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  const CustomBackButton(),
                  SizedBox(height: 20.h),

                  // Segmented toggle
                  _SegmentedToggle(
                    leftText: 'Request transport',
                    rightText: 'Track shipments',
                    value: controller.segment,
                    onChanged: (v) {
                      controller.setSegment(v);
                      if (v == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Go to Request transport')),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Search
                  TextField(
                    controller: _search,
                    onChanged: controller.setQuery,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search you product',
                      hintStyle: TextStyle(color: AllColor.textHintColor),
                      prefixIcon: Icon(Icons.search_rounded, color: AllColor.black54),
                      filled: true,
                      fillColor: AllColor.grey100,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.r),
                        borderSide: BorderSide(color: AllColor.grey200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.r),
                        borderSide: BorderSide(color: AllColor.grey200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.r),
                        borderSide: BorderSide(color: AllColor.blue500),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Tabs
                  Row(
                    children: [
                      _TabChip(
                        text: 'Pending',
                        selected: controller.status == OrderStatus.pending,
                        onTap: () => controller.setStatus(OrderStatus.pending),
                      ),
                      SizedBox(width: 8.w),
                      _TabChip(
                        text: 'Completed',
                        selected: controller.status == OrderStatus.completed,
                        onTap: () => controller.setStatus(OrderStatus.completed),
                      ),
                      SizedBox(width: 8.w),
                      _TabChip(
                        text: 'Cancelled',
                        selected: controller.status == OrderStatus.cancelled,
                        onTap: () => controller.setStatus(OrderStatus.cancelled),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // List
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(0, 6.h, 0, 16.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, i) => _ShipmentCard(
                        data: items[i],
                        selected: controller.selectedIndex == i &&
                            controller.status == OrderStatus.pending, // optional blue outline
                        onTap: () {
                          controller.selectIndex(i);
                          // TODO: navigate to details if needed
                          // context.go('/vendor/shipments/details?id=${items[i].orderNo}');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =============================== UI PARTS =============================== */

class _SegmentedToggle extends StatelessWidget {
  final String leftText;
  final String rightText;
  final int value; // 0/1
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget seg(String text, bool active, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            height: 38.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AllColor.loginButtomColor : AllColor.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: active ? AllColor.loginButtomColor : AllColor.grey200,
              ),
              boxShadow: active
                  ? [BoxShadow(color: Colors.black12, blurRadius: 6.r, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Text(
              text,
              style: TextStyle(
                color: active ? AllColor.white : AllColor.black,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        seg(leftText, value == 0, () => onChanged(0)),
        SizedBox(width: 8.w),
        seg(rightText, value == 1, () => onChanged(1)),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AllColor.loginButtomColor : AllColor.grey100,
          borderRadius: BorderRadius.circular(20.r),
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
}

class _ShipmentCard extends StatelessWidget {
  final ShipmentItem data;
  final VoidCallback onTap;
  final bool selected;
  const _ShipmentCard({required this.data, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final Widget pill = switch (data.status) {
      OrderStatus.pending   => _StatusPill('Pending', AllColor.loginButtomColor, solid: false),
      OrderStatus.completed => _StatusPill('Complete', Colors.green, solid: false),
      OrderStatus.cancelled => _StatusPill('Cancelled', Colors.redAccent, solid: true),
    };

    return Material(
      color: AllColor.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: selected
                ? Border.all(color: AllColor.blue500, width: 2.w)
                : Border.all(color: AllColor.grey200),
          ),
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: Order # + status pill
              Row(
                children: [
                  Text(
                    'Order #${data.orderNo}',
                    style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  pill,
                ],
              ),
              SizedBox(height: 10.h),

              // Middle: thumbnail + info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      height: 56.h,
                      width: 56.w,
                      color: AllColor.grey100,
                      child: Image.network(data.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title,
                            style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6.h),
                        Text(data.customer,
                            style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w700)),
                        Text(data.address, style: TextStyle(color: AllColor.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Bottom: qty + price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Qty: ${data.qty}', style: TextStyle(color: AllColor.black54)),
                  Text('\$${data.price.toStringAsFixed(0)}',
                      style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w800, fontSize: 18.sp)),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Order placed on ${data.date}',
                style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final bool solid;
  const _StatusPill(this.text, this.color, {this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: solid ? color : color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20.r),
        border: solid ? null : Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: solid ? Colors.white : color,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

/* ============================ DEMO DATA ============================ */

final _demoItems = <ShipmentItem>[
  ShipmentItem(
    orderNo: '12345',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    address: '6391 Elgin St. Celina,',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600',
    status: OrderStatus.pending,
  ),
  ShipmentItem(
    orderNo: '12346',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    address: '6391 Elgin St. Celina,',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
    status: OrderStatus.pending,
  ),
  ShipmentItem(
    orderNo: '22345',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    address: '6391 Elgin St. Celina,',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
    status: OrderStatus.completed,
  ),
  ShipmentItem(
    orderNo: '32345',
    title: 'Balack t shirt x1\nwhite shoe x3',
    customer: 'John doe',
    address: '6391 Elgin St. Celina,',
    qty: 4,
    date: '10 july 2025',
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=601',
    status: OrderStatus.cancelled,
  ),
];
