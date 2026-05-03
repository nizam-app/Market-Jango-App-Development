import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/data/asign_to_order_driver_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/logic/vendor_driver_prement_logic.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/model/asign_to_order_driver_model.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_order_assign_rules.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// Pass this as `GoRouterState.extra` when opening [AssignToOrderDriver].
class AssignToOrderDriverArgs {
  const AssignToOrderDriverArgs({required this.driverId, this.driverName});

  final int driverId;
  final String? driverName;
}

class AssignToOrderDriver extends ConsumerStatefulWidget {
  const AssignToOrderDriver({
    super.key,
    required this.driverId,
    this.driverName,
  });

  static const routeName = "/assign_order_driver";

  final int driverId;
  /// Display name from driver list; falls back to numeric id in titles.
  final String? driverName;

  /// Text after "Assign order to driver …" (name or `#id`).
  String get driverDisplaySuffix {
    final n = driverName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return '$driverId';
  }

  @override
  ConsumerState<AssignToOrderDriver> createState() =>
      _AssignToOrderDriverState();
}

class _AssignToOrderDriverState extends ConsumerState<AssignToOrderDriver> {
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

    return async.when(
      loading: () => const Scaffold(
        body: SafeArea(child: Center(child: Text('Loading...'))),
      ),
      error: (e, _) => Scaffold(
        body: SafeArea(child: Center(child: Text(e.toString()))),
      ),
      data: (pageData) {
        final orders = pageData.data;
        // API may return any line status; server only allows assign for pending/processing.
        final assignable = orders
            .where(
              (o) => VendorOrderAssignRules.isPendingOrProcessingStatus(o.status),
            )
            .toList();

        // search filter (only among assignable lines)
        final q = _search.text.trim().toLowerCase();
        final items = assignable.where((o) {
          final orderNo = _orderNo(o).toLowerCase();
          final line1 = _line1(o).toLowerCase();
          final line2 = _line2(o).toLowerCase();
          if (q.isEmpty) return true;
          return orderNo.contains(q) || line1.contains(q) || line2.contains(q);
        }).toList();

        // jodi page change / search e selected index out of range hoy
        if (_selectedIndex != null && _selectedIndex! >= items.length) {
          _selectedIndex = null;
        }

        return Scaffold(
          backgroundColor: AllColor.white,

          // 🔹 Bottom button ta ekdom alada rakhlam — overflow possible na
          bottomNavigationBar: _BottomAssignBar(
            driverDisplaySuffix: widget.driverDisplaySuffix,
            enabled: _selectedIndex != null && items.isNotEmpty,
            onPressed: _selectedIndex == null
                ? null
                : () async {
                    final chosen = items[_selectedIndex!];

                    await startVendorAssignCheckout(
                      context,
                      ref,
                      driverId: widget.driverId,
                      orderItemId: chosen.id, // invoice_item_id / line id
                    );
                  },
          ),

          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Header + search part
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomBackButton(),
                      SizedBox(height: 20.h),
                      Text(
                        'Assign order to driver ${widget.driverDisplaySuffix}',
                        style: TextStyle(
                          color: AllColor.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Only order lines in Pending or Processing can be assigned.',
                        style: TextStyle(
                          color: AllColor.black54,
                          fontSize: 12.sp,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          //'Search orders',
                          hintText: ref.t(BKeys.searchOrders),
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
                    ],
                  ),
                ),

                // 🔹 Full scroll area: list + pagination
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                assignable.isEmpty && orders.isNotEmpty
                                    ? 'No lines on this page can be assigned. '
                                        'Delivered, cancelled, and other final '
                                        'statuses are hidden. Try another page or '
                                        'wait until an order is Pending or Processing.'
                                    : orders.isEmpty
                                        ? 'No orders on this page.'
                                        : 'No matching orders for your search.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AllColor.black54,
                                  fontSize: 14.sp,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 12.h),
                            itemCount: items.length + 1,
                            separatorBuilder: (context, index) {
                              // last separator = gap before pagination
                              if (index < items.length - 1) {
                                return const Divider(height: 1);
                              }
                              return SizedBox(height: 12.h);
                            },
                            itemBuilder: (context, index) {
                              // last row = pagination
                              if (index == items.length) {
                                return GlobalPagination(
                                  currentPage: pageData.currentPage,
                                  totalPages: pageData.lastPage,
                                  onPageChanged: (newPage) {
                                    setState(() => _selectedIndex = null);
                                    ref
                                            .read(
                                              vendorPendingCurrentPageProvider
                                                  .notifier,
                                            )
                                            .state =
                                        newPage;
                                  },
                                );
                              }

                              final item = items[index];

                              return InkWell(
                                onTap: () =>
                                    setState(() => _selectedIndex = index),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.w),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // radio
                                      Radio<int>(
                                        value: index,
                                        groupValue: _selectedIndex,
                                        onChanged: (v) =>
                                            setState(() => _selectedIndex = v),
                                        activeColor: AllColor.loginButtomColor,
                                      ),
                                      SizedBox(width: 6.w),

                                      // texts
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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

                                      // status text
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          _formatStatusLabel(item.status),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== helper text =====
  String _orderNo(VendorPendingOrder o) =>
      o.tranId.isNotEmpty ? o.tranId : o.id.toString();

  String _line1(VendorPendingOrder o) =>
      'Qty: ${o.quantity} • Sale: ${o.salePrice.toStringAsFixed(2)}';

  /// line2 = pickup_address (fallback ship_address)
  String _line2(VendorPendingOrder o) {
    final pickup = (o.pickupAddress ?? '').trim();
    final ship = (o.shipAddress ?? '').trim();

    if (pickup.isNotEmpty) {
      return 'Pickup: $pickup';
    } else if (ship.isNotEmpty) {
      return 'Ship to: $ship';
    } else {
      return 'Pickup address: Not set';
    }
  }

  String _formatStatusLabel(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '—';
    final lower = t.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

/// ================= Bottom button =================

class _BottomAssignBar extends StatelessWidget {
  final String driverDisplaySuffix;
  final bool enabled;
  final VoidCallback? onPressed;

  const _BottomAssignBar({
    required this.driverDisplaySuffix,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Keep in sync with the screen title: "Assign order to driver {name|id}".
    final label = 'Assign order to driver $driverDisplaySuffix';
    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AllColor.loginButtomColor,
            disabledBackgroundColor: AllColor.grey200,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AllColor.white,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

