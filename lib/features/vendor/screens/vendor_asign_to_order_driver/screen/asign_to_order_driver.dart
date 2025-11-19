import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/data/asign_to_order_driver_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/model/asign_to_order_driver_model.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
class AssignToOrderDriver extends ConsumerStatefulWidget {
  const AssignToOrderDriver({
    super.key,
    this.driverName = 'Murphy',
  });

  static const routeName = "/assign_order_driver";

  final String driverName;

  @override
  ConsumerState<AssignToOrderDriver> createState() =>
      _AssignToOrderDriverState();
}

class _AssignToOrderDriverState
    extends ConsumerState<AssignToOrderDriver> {
  final _search = TextEditingController();
  int? _selectedIndex;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(vendorPendingOrdersProvider);

    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (orders) => _buildBody(context, orders),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<VendorPendingOrder> orders) {
    // search filter
    final q = _search.text.trim().toLowerCase();

    final items = orders.where((o) {
      final orderNo = _orderNo(o).toLowerCase();
      final line1 = _line1(o).toLowerCase();
      final line2 = _line2(o).toLowerCase();
      if (q.isEmpty) return true;
      return orderNo.contains(q) || line1.contains(q) || line2.contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomBackButton(),
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
                                'Order #${_orderNo(item)}',
                                style: TextStyle(
                                  color: AllColor.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _line1(item),
                                style: TextStyle(
                                  color: AllColor.black54,
                                  fontSize: 13.sp,
                                ),
                              ),
                              Text(
                                _line2(item),
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
                            item.status,
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

          // Bottom CTA
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
                      final chosen = items[_selectedIndex!];
                      // TODO: এখানে assign API call করতে পারো / pop করতে পারো
                      // এখন একই মতো demo navigation রাখলাম
                      context.push("/addCard", extra: chosen);
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
    );
  }

  // ===== helper text =====
  String _orderNo(VendorPendingOrder o) =>
      o.tranId.isNotEmpty ? o.tranId : o.id.toString();

  String _line1(VendorPendingOrder o) =>
      'Qty: ${o.quantity} • Sale: ${o.salePrice.toStringAsFixed(2)}';

  String _line2(VendorPendingOrder o) {
    final total = o.invoice?.total ?? o.invoice?.subTotal ?? '';
    return total.isEmpty ? 'Invoice #${o.invoiceId}' : 'Invoice total: $total';
  }
}