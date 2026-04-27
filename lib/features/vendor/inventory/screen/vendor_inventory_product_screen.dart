import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/inventory/data/vendor_inventory_api.dart';
import 'package:market_jango/features/vendor/inventory/model/vendor_inventory_model.dart';
import 'package:market_jango/features/vendor/screens/product_edit/logic/update_product_riverpod.dart';

final Set<int> _stockUpdateInFlight = <int>{};

class _SummaryDateFilter {
  const _SummaryDateFilter({this.from, this.to});
  final DateTime? from;
  final DateTime? to;

  _SummaryDateFilter copyWith({
    DateTime? from,
    DateTime? to,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return _SummaryDateFilter(
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
    );
  }

  bool get hasFilter => from != null || to != null;
}

final _summaryDateFilterProvider =
    StateProvider.family<_SummaryDateFilter, int>(
  (ref, productId) => const _SummaryDateFilter(),
);

class VendorInventoryProductScreen extends ConsumerWidget {
  const VendorInventoryProductScreen({super.key, required this.productId});

  final int productId;

  static const String routeName = '/vendor/inventory/product';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogs = ref.watch(vendorInventoryLogsProvider(productId));
    final asyncSummary = ref.watch(vendorInventorySummaryProvider(productId));
    final summaryFilter = ref.watch(_summaryDateFilterProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Inventory Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: asyncLogs.when(
          data: (res) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(vendorInventoryLogsProvider(productId));
                ref.invalidate(vendorInventorySummaryProvider(productId));
              },
              child: ListView(
                children: [
                  if (res.product.images.isNotEmpty) ...[
                    SizedBox(
                      height: 92.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: res.product.images.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, i) {
                          final img = res.product.images[i].imagePath.trim();
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                color: Colors.grey.shade200,
                                child: img.isEmpty
                                    ? Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey.shade500,
                                      )
                                    : Image.network(
                                        img,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          res.product.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _showStockUpdateDialog(
                          context,
                          ref,
                          productId: res.product.id,
                          currentStock: res.product.stock,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AllColor.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Stock: ${res.product.stock}',
                                style: TextStyle(
                                  color: AllColor.orange,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.edit_outlined,
                                size: 15.sp,
                                color: AllColor.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Action summary',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  _SummaryFilterBar(
                    filter: summaryFilter,
                    onPickFrom: () => _pickSummaryDate(
                      context,
                      ref,
                      productId: productId,
                      isFrom: true,
                    ),
                    onPickTo: () => _pickSummaryDate(
                      context,
                      ref,
                      productId: productId,
                      isFrom: false,
                    ),
                    onClear: () {
                      ref
                          .read(_summaryDateFilterProvider(productId).notifier)
                          .state = const _SummaryDateFilter();
                    },
                  ),
                  SizedBox(height: 8.h),
                  asyncSummary.when(
                    data: (events) {
                      final filteredEvents =
                          _filterSummaryEvents(events, summaryFilter);
                      if (filteredEvents.isEmpty) {
                        return _EmptyCard(
                          icon: Icons.timeline_outlined,
                          title: summaryFilter.hasFilter
                              ? 'No events in this time'
                              : 'No summary yet',
                          message: summaryFilter.hasFilter
                              ? 'Try changing or clearing the time filter.'
                              : 'No stock events found for this product. When sales/restocks happen, summary will appear here.',
                        );
                      }
                      return Column(
                        children: filteredEvents.take(20).map((e) {
                          final isPlus = e.direction.trim() == '+';
                          final color = isPlus ? Colors.green : Colors.red;
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AllColor.grey.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DeltaBadge(
                                  delta: e.quantityChange,
                                  color: color,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _prettyChangeType(e.changeType),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Actor: ${e.actorName.isEmpty ? 'system' : e.actorName}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Time: ${_formatTime(e.time)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    ),
                    error: (e, _) => Text('Summary error: $e'),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Details (expand items)',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  if (res.logs.isEmpty)
                    _EmptyCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'No inventory logs',
                      message:
                          'This product has no stock change history yet.',
                    ),
                  ...res.logs.map((l) => _LogExpansionTile(log: l)),
                  SizedBox(height: 8.h),
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

Future<void> _showStockUpdateDialog(
  BuildContext context,
  WidgetRef ref, {
  required int productId,
  required int currentStock,
}) async {
  var closing = false;
  var displayStock = currentStock;
  var apiDelta = 0;
  DateTime? lastStepAt;

  void applyStep(int direction, void Function(void Function()) setDialogState) {
    final now = DateTime.now();
    final last = lastStepAt;
    if (last != null && now.difference(last).inMilliseconds < 300) return;
    lastStepAt = now;
    setDialogState(() {
      displayStock += direction * 2;
      apiDelta += direction;
    });
  }

  final newStock = await showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final displayDifference = displayStock - currentStock;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('Update stock'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current stock: $currentStock',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7FA),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StockStepButton(
                        icon: Icons.remove,
                        enabled: !closing && (currentStock + apiDelta) > 0,
                        onTap: () => applyStep(-1, setDialogState),
                      ),
                      SizedBox(width: 18.w),
                      Column(
                        children: [
                          Text(
                            '$displayStock',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: AllColor.orange,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            displayDifference == 0
                                ? 'No change'
                                : '${displayDifference > 0 ? '+' : ''}$displayDifference',
                            style: TextStyle(
                              color: displayDifference == 0
                                  ? Colors.grey.shade600
                                  : (displayDifference > 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 18.w),
                      _StockStepButton(
                        icon: Icons.add,
                        enabled: !closing,
                        onTap: () => applyStep(1, setDialogState),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'UI changes by 2, but stock updates by 1 per click.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: closing ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColor.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: closing
                    ? null
                    : () {
                        setDialogState(() => closing = true);
                        Navigator.of(dialogContext).pop(currentStock + apiDelta);
                      },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );

  if (newStock == null || newStock == currentStock) return;
  if (_stockUpdateInFlight.contains(productId)) return;

  try {
    _stockUpdateInFlight.add(productId);
    final ok = await ref.read(updateProductProvider.notifier).updateProduct(
          id: productId,
          stock: newStock.toString(),
        );

    if (!context.mounted) return;
    if (ok) {
      ref.invalidate(vendorInventoryProvider);
      ref.invalidate(vendorInventoryLogsProvider(productId));
      ref.invalidate(vendorInventorySummaryProvider(productId));
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Stock updated successfully',
      );
    } else {
      final state = ref.read(updateProductProvider);
      final message = state.maybeWhen(
        error: (error, _) => error.toString(),
        orElse: () => 'Failed to update stock',
      );
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: message,
        type: CustomSnackType.error,
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    GlobalSnackbar.show(
      context,
      title: 'Error',
      message: e.toString(),
      type: CustomSnackType.error,
    );
  } finally {
    _stockUpdateInFlight.remove(productId);
  }
}

Future<void> _pickSummaryDate(
  BuildContext context,
  WidgetRef ref, {
  required int productId,
  required bool isFrom,
}) async {
  final current = ref.read(_summaryDateFilterProvider(productId));
  final initial = (isFrom ? current.from : current.to) ?? DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime(DateTime.now().year + 2),
  );
  if (picked == null) return;

  final normalized = DateTime(picked.year, picked.month, picked.day);
  final notifier = ref.read(_summaryDateFilterProvider(productId).notifier);
  notifier.state = isFrom
      ? current.copyWith(from: normalized)
      : current.copyWith(to: normalized);
}

List<VendorInventorySummaryEvent> _filterSummaryEvents(
  List<VendorInventorySummaryEvent> events,
  _SummaryDateFilter filter,
) {
  if (!filter.hasFilter) return events;
  return events.where((event) {
    final dt = DateTime.tryParse(event.time);
    if (dt == null) return false;
    final day = DateTime(dt.year, dt.month, dt.day);
    final from = filter.from;
    final to = filter.to;
    if (from != null && day.isBefore(from)) return false;
    if (to != null && day.isAfter(to)) return false;
    return true;
  }).toList();
}

String _dateLabel(DateTime? date, String fallback) {
  if (date == null) return fallback;
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _SummaryFilterBar extends StatelessWidget {
  const _SummaryFilterBar({
    required this.filter,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClear,
  });

  final _SummaryDateFilter filter;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateFilterButton(
            label: _dateLabel(filter.from, 'From date'),
            onTap: onPickFrom,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _DateFilterButton(
            label: _dateLabel(filter.to, 'To date'),
            onTap: onPickTo,
          ),
        ),
        if (filter.hasFilter) ...[
          SizedBox(width: 6.w),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AllColor.grey.withOpacity(0.18)),
              ),
              child: Icon(Icons.close, size: 18.sp, color: Colors.grey.shade700),
            ),
          ),
        ],
      ],
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AllColor.grey.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 14.sp, color: AllColor.orange),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockStepButton extends StatelessWidget {
  const _StockStepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: enabled ? (_) => onTap() : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: AllColor.orange,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22.sp),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AllColor.grey.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AllColor.orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AllColor.orange),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta, required this.color});
  final int delta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isPlus = delta >= 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${isPlus ? '+' : ''}$delta',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _LogExpansionTile extends StatelessWidget {
  const _LogExpansionTile({required this.log});
  final VendorInventoryLog log;

  @override
  Widget build(BuildContext context) {
    final delta = log.quantityChange;
    final isPlus = delta >= 0;
    final color = isPlus ? Colors.green : Colors.red;
    final actor = log.actorName.trim().isEmpty ? 'system' : log.actorName.trim();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AllColor.grey.withOpacity(0.15)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          leading: _DeltaBadge(delta: delta, color: color),
          title: Text(
            _prettyChangeType(log.changeType),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actor: $actor',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Time: ${_formatTime(log.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          children: [
            _kv('Stock before', log.quantityBefore?.toString() ?? '-'),
            _kv('Stock after', log.quantityAfter.toString()),
            _kv('Change type', _prettyChangeType(log.changeType)),
            if (log.referenceType != null && log.referenceType!.trim().isNotEmpty)
              _kv('Reference', _refLabel(log.referenceType, log.referenceId)),
            if (log.note != null && log.note!.trim().isNotEmpty)
              _kv('Note', log.note!.trim()),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              k,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(fontSize: 12.sp, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  String _refLabel(String? type, int? id) {
    final t = type?.trim();
    if (t == null || t.isEmpty) return '-';
    if (id == null || id <= 0) return t;
    return '$t #$id';
  }
}

String _prettyChangeType(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return 'Event';
  return s.replaceAll('_', ' ').split(' ').map((w) {
    if (w.isEmpty) return w;
    return '${w[0].toUpperCase()}${w.substring(1)}';
  }).join(' ');
}

String _formatTime(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

