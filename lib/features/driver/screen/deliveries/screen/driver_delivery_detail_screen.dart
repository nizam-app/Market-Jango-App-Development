import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/driver/screen/deliveries/data/driver_deliveries_api.dart';
import 'package:market_jango/features/driver/screen/deliveries/model/driver_assignment_models.dart';
import 'package:market_jango/features/driver/screen/deliveries/provider/driver_deliveries_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// `GET/POST .../api/driver/deliveries/{id}/...` — `doc/details.md`.
class DriverDeliveryDetailScreen extends ConsumerStatefulWidget {
  const DriverDeliveryDetailScreen({super.key, required this.assignmentId});

  final int assignmentId;

  /// Use with GoRouter path `/driver/deliveries/:assignmentId`.
  static String routePath(int id) => '/driver/deliveries/$id';

  @override
  ConsumerState<DriverDeliveryDetailScreen> createState() =>
      _DriverDeliveryDetailScreenState();
}

class _DriverDeliveryDetailScreenState
    extends ConsumerState<DriverDeliveryDetailScreen> {
  bool _busy = false;
  Timer? _locationTimer;
  bool _autoLocation = false;

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _invalidate() async {
    ref.invalidate(driverDeliveryDetailProvider(widget.assignmentId));
    ref.invalidate(driverDeliveriesListProvider);
    await ref.read(driverDeliveryDetailProvider(widget.assignmentId).future);
  }

  Future<void> _run(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      if (mounted) await _invalidate();
    } catch (e) {
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Error',
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendLocation({bool quiet = false}) async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!quiet && mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Location',
            message: 'Location permission denied.',
            type: CustomSnackType.error,
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      await DriverDeliveriesApi.instance.postLocation(
        widget.assignmentId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: pos.heading,
        speed: pos.speed >= 0 ? pos.speed : null,
      );
      if (!quiet && mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Location',
          message: 'GPS sent',
          type: CustomSnackType.success,
        );
      }
    } catch (e) {
      if (!quiet && mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Location',
          message: e.toString().replaceFirst('Exception: ', ''),
          type: CustomSnackType.error,
        );
      }
    }
  }

  void _setAutoLocation(bool on, DriverAssignmentRow row) {
    final st = row.status;
    final can = st == 'accepted' || st == 'in_transit';
    if (!can) return;

    _locationTimer?.cancel();
    _locationTimer = null;
    setState(() => _autoLocation = on);
    if (on) {
      _locationTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _sendLocation(quiet: true);
      });
      _sendLocation(quiet: true);
    }
  }

  Future<void> _showRejectDialog() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject delivery'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Required (max 500 chars)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final reason = ctrl.text.trim();
    if (reason.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Validation',
        message: 'Reason is required.',
        type: CustomSnackType.error,
      );
      return;
    }
    await _run(() async {
      await DriverDeliveriesApi.instance.reject(
        widget.assignmentId,
        reason: reason,
      );
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Done',
        message: 'Assignment rejected',
        type: CustomSnackType.success,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(driverDeliveryDetailProvider(widget.assignmentId), (prev, next) {
      if (next.hasValue) {
        final st = next.value!.status;
        if (st != 'accepted' && st != 'in_transit') {
          _locationTimer?.cancel();
          _locationTimer = null;
          if (_autoLocation && mounted) {
            setState(() => _autoLocation = false);
          }
        }
      }
    });

    final async = ref.watch(driverDeliveryDetailProvider(widget.assignmentId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          'Assignment #${widget.assignmentId}',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(driverDeliveryDetailProvider(widget.assignmentId));
              await ref.read(
                driverDeliveryDetailProvider(widget.assignmentId).future,
              );
            },
            child: async.when(
              loading: () => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
              error: (e, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                children: [
                  Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    style: TextStyle(color: AllColor.red, fontSize: 13.sp),
                  ),
                ],
              ),
              data: (row) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                children: [
                  _StatusCard(row: row),
                  SizedBox(height: 12.h),
                  Text(
                    row.displaySubtitle,
                    style: TextStyle(fontSize: 13.sp, height: 1.35),
                  ),
                  if (row.raw['latest_location'] != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      'Last known: ${row.raw['latest_location']}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AllColor.grey500,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 24.h),
                  _ActionsSection(
                    row: row,
                    busy: _busy,
                    autoLocation: _autoLocation,
                    onAccept: () => _run(() async {
                      await DriverDeliveriesApi.instance
                          .accept(widget.assignmentId);
                      if (!mounted) return;
                      GlobalSnackbar.show(
                        context,
                        title: 'Done',
                        message: 'Accepted',
                        type: CustomSnackType.success,
                      );
                    }),
                    onReject: _showRejectDialog,
                    onPickup: () => _run(() async {
                      await DriverDeliveriesApi.instance
                          .pickup(widget.assignmentId);
                      if (!mounted) return;
                      GlobalSnackbar.show(
                        context,
                        title: 'Done',
                        message: 'Marked picked up (in transit)',
                        type: CustomSnackType.success,
                      );
                    }),
                    onDeliver: () => _run(() async {
                      await DriverDeliveriesApi.instance
                          .deliver(widget.assignmentId);
                      if (!mounted) return;
                      GlobalSnackbar.show(
                        context,
                        title: 'Done',
                        message: 'Delivered',
                        type: CustomSnackType.success,
                      );
                    }),
                    onSendLocation: () => _sendLocation(quiet: false),
                    onAutoLocation: (v) => _setAutoLocation(v, row),
                  ),
                ],
              ),
            ),
          ),
          if (_busy)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.row});
  final DriverAssignmentRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AllColor.grey200),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: AllColor.blue500),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColor.grey500,
                    ),
                  ),
                  Text(
                    row.status,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.row,
    required this.busy,
    required this.autoLocation,
    required this.onAccept,
    required this.onReject,
    required this.onPickup,
    required this.onDeliver,
    required this.onSendLocation,
    required this.onAutoLocation,
  });

  final DriverAssignmentRow row;
  final bool busy;
  final bool autoLocation;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onPickup;
  final VoidCallback onDeliver;
  final VoidCallback onSendLocation;
  final ValueChanged<bool> onAutoLocation;

  @override
  Widget build(BuildContext context) {
    final st = row.status;
    final children = <Widget>[];

    if (st == 'pending') {
      children.addAll([
        FilledButton(
          onPressed: busy ? null : onAccept,
          child: const Text('Accept'),
        ),
        SizedBox(height: 10.h),
        OutlinedButton(
          onPressed: busy ? null : onReject,
          child: const Text('Reject'),
        ),
      ]);
    } else if (st == 'accepted') {
      children.add(
        FilledButton(
          onPressed: busy ? null : onPickup,
          child: const Text('Mark picked up (in transit)'),
        ),
      );
      children.add(SizedBox(height: 12.h));
      children.add(
        OutlinedButton.icon(
          onPressed: busy ? null : onSendLocation,
          icon: const Icon(Icons.my_location, size: 18),
          label: const Text('Send location now'),
        ),
      );
      children.add(SizedBox(height: 8.h));
      children.add(
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-send location every 15s'),
          value: autoLocation,
          onChanged: busy ? null : onAutoLocation,
        ),
      );
    } else if (st == 'in_transit') {
      children.add(
        FilledButton(
          onPressed: busy ? null : onDeliver,
          child: const Text('Mark delivered'),
        ),
      );
      children.add(SizedBox(height: 12.h));
      children.add(
        OutlinedButton.icon(
          onPressed: busy ? null : onSendLocation,
          icon: const Icon(Icons.my_location, size: 18),
          label: const Text('Send location now'),
        ),
      );
      children.add(SizedBox(height: 8.h));
      children.add(
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto-send location every 15s'),
          value: autoLocation,
          onChanged: busy ? null : onAutoLocation,
        ),
      );
    } else {
      children.add(
        Text(
          'No actions for this status.',
          style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
