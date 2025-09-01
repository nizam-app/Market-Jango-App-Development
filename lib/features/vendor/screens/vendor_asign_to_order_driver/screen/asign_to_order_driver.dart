import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class AsignToOrderDriver extends StatefulWidget {
  const AsignToOrderDriver({super.key, this.driverName = 'Murphy'});
  static const routeName = "/assign_order_driver";

  final String driverName;

  @override
  State<AsignToOrderDriver> createState() => _AsignToOrderDriverState();
}

class _AsignToOrderDriverState extends State<AsignToOrderDriver> {
  final _search = TextEditingController();
  int? _selectedIndex;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // filter by search
    final items = _demoOrders.where((o) {
      final q = _search.text.trim().toLowerCase();
      return q.isEmpty ||
          o.orderNo.toLowerCase().contains(q) ||
          o.address1.toLowerCase().contains(q) ||
          o.address2.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton(),
              SizedBox(height: 20.h),
              Text(
                'Assign order to driver ${widget.driverName}',
                style: TextStyle(
                  color: AllColor.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),

              // Search
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search orders',
                  hintStyle: TextStyle(color: AllColor.textHintColor),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AllColor.black54,
                  ),
                  filled: true,
                  fillColor: AllColor.grey100,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
              ),
              SizedBox(height: 12.h),

              // Orders list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final selected = i == _selectedIndex;
                    return InkWell(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Radio
                            Radio<int>(
                              value: i,
                              groupValue: _selectedIndex,
                              onChanged: (v) =>
                                  setState(() => _selectedIndex = v),
                              activeColor: AllColor.loginButtomColor,
                            ),
                            SizedBox(width: 6.w),

                            // Order texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${item.orderNo}',
                                    style: TextStyle(
                                      color: AllColor.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.address1,
                                    style: TextStyle(
                                      color: AllColor.black54,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  Text(
                                    item.address2,
                                    style: TextStyle(
                                      color: AllColor.black54,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Status
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                'Pending',
                                style: TextStyle(
                                  color: AllColor.blue500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom CTA + grabber
              Container(
                color: AllColor.white,
                padding: EdgeInsets.only(
                  left: 16.h,
                  right: 16.h,
                  top: 6.h,
                  bottom: 10.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: _selectedIndex == null
                            ? null
                            : () {
                                //final chosen = items[_selectedIndex!];
                                //Navigation to Add Card Screen
                                context.push("/addCard");
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColor.loginButtomColor,
                          disabledBackgroundColor: AllColor.grey200,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Book now',
                          style: TextStyle(
                            color: AllColor.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =================== Demo model & data =================== */

class AssignOrderItem {
  final String orderNo;
  final String address1;
  final String address2;

  const AssignOrderItem({
    required this.orderNo,
    required this.address1,
    required this.address2,
  });
}

const _demoOrders = <AssignOrderItem>[
  AssignOrderItem(
    orderNo: '100134',
    address1: '4517 Washington Ave.',
    address2: 'Manchester, Kentucky 39495',
  ),
  AssignOrderItem(
    orderNo: '100135',
    address1: '4517 Washington Ave.',
    address2: 'Manchester, Kentucky 39495',
  ),
  AssignOrderItem(
    orderNo: '100134',
    address1: '4517 Washington Ave.',
    address2: 'Manchester, Kentucky 39495',
  ),
  AssignOrderItem(
    orderNo: '100134',
    address1: '4517 Washington Ave.',
    address2: 'Manchester, Kentucky 39495',
  ),
  AssignOrderItem(
    orderNo: '100134',
    address1: '4517 Washington Ave.',
    address2: 'Manchester, Kentucky 39495',
  ),
  AssignOrderItem(
    orderNo: '100134',
    address1: '4517 Washington Ave.',
    address2: 'Manchester, Kentucky 39495',
  ),
];
