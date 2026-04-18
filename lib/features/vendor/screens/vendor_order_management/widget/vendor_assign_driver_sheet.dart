import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/widget/vendor_order_assign_rules.dart';

/// Bottom sheet to pick an available driver for an invoice line (order item).
class VendorAssignDriverSheet extends StatefulWidget {
  const VendorAssignDriverSheet({
    super.key,
    required this.lineId,
    required this.invoiceStatus,
    required this.lineStatus,
    required this.onAssigned,
    required this.onAssignFailed,
  });

  final int lineId;
  final String invoiceStatus;
  final String lineStatus;
  final Future<void> Function() onAssigned;
  final Future<void> Function() onAssignFailed;

  @override
  State<VendorAssignDriverSheet> createState() => _VendorAssignDriverSheetState();
}

class _VendorAssignDriverSheetState extends State<VendorAssignDriverSheet> {
  final _search = TextEditingController();
  List<VendorAvailableDriver> _drivers = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final q = _search.text.trim();
      final list = await VendorOrderApi.instance.fetchAvailableDrivers(
        search: q.isEmpty ? null : q,
      );
      if (mounted) {
        setState(() {
          _drivers = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _assign(VendorAvailableDriver dr) async {
    if (!VendorOrderAssignRules.sheetAllowsAssignDriver(
      widget.invoiceStatus,
      widget.lineStatus,
    )) {
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Cannot assign driver',
        message:
            'This line must be Pending or Processing to assign a driver.',
        type: CustomSnackType.error,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await VendorOrderApi.instance.assignDriverToOrderItem(
        invoiceItemId: widget.lineId,
        driverId: dr.id,
      );
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Assigned',
        message: 'Driver assigned to this line',
        type: CustomSnackType.success,
      );
      await widget.onAssigned();
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Cannot assign driver',
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackType.error,
          duration: const Duration(seconds: 4),
        );
        setState(() => _submitting = false);
        await widget.onAssignFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Available drivers',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColor.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loading || _submitting
                    ? null
                    : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                  onSubmitted: (_) => _fetch(),
                ),
              ),
              SizedBox(width: 8.w),
              FilledButton(
                onPressed: _loading || _submitting ? null : _fetch,
                style: FilledButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                ),
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AllColor.grey500,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                )
              : _drivers.isEmpty
              ? Center(
                  child: Text(
                    'No drivers match your search.',
                    style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _drivers.length,
                  itemBuilder: (ctx, i) {
                    final dr = _drivers[i];
                    final label = dr.name.isEmpty
                        ? 'Driver #${dr.id}'
                        : dr.name;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(label),
                      trailing: _submitting
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: _submitting ? null : () => _assign(dr),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
