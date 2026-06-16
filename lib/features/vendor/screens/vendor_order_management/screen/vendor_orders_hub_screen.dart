import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/provider/vendor_orders_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

import 'vendor_create_manual_order_screen.dart';
import 'vendor_manual_order_detail_screen.dart';
import 'vendor_marketplace_order_detail_screen.dart';
import 'vendor_refunds_tab.dart';

/// Entry: marketplace orders (date range), walk-in orders, wallet — see doc/VENDOR_ORDER_MANAGEMENT_AND_BILLING.md
class VendorOrdersHubScreen extends ConsumerStatefulWidget {
  const VendorOrdersHubScreen({super.key});

  static const routeName = '/vendor/order-management';

  @override
  ConsumerState<VendorOrdersHubScreen> createState() =>
      _VendorOrdersHubScreenState();
}

class _VendorOrdersHubScreenState extends ConsumerState<VendorOrdersHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _orderNoMp = TextEditingController();
  final _orderNoMan = TextEditingController();
  String? _statusMp;
  String? _statusMan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderNoMp.dispose();
    _orderNoMan.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool isFrom,
    required bool marketplace,
  }) async {
    final now = DateTime.now();
    final initial = now;
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDate: initial,
    );
    if (d == null) return;
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final formatted = '$y-$m-$day';
    if (marketplace) {
      final n = ref.read(vendorMarketplaceListParamsProvider.notifier);
      final cur = ref.read(vendorMarketplaceListParamsProvider);
      n.state = cur.copyWith(
        page: 1,
        fromDate: isFrom ? formatted : cur.fromDate,
        toDate: !isFrom ? formatted : cur.toDate,
      );
    } else {
      final n = ref.read(vendorManualListParamsProvider.notifier);
      final cur = ref.read(vendorManualListParamsProvider);
      n.state = cur.copyWith(
        page: 1,
        fromDate: isFrom ? formatted : cur.fromDate,
        toDate: !isFrom ? formatted : cur.toDate,
      );
    }
  }

  void _clearDates(bool marketplace) {
    if (marketplace) {
      final n = ref.read(vendorMarketplaceListParamsProvider.notifier);
      n.state = ref
          .read(vendorMarketplaceListParamsProvider)
          .copyWith(page: 1, clearDates: true);
    } else {
      final n = ref.read(vendorManualListParamsProvider.notifier);
      n.state = ref
          .read(vendorManualListParamsProvider)
          .copyWith(page: 1, clearDates: true);
    }
  }

  void _applySearch(bool marketplace) {
    if (marketplace) {
      final n = ref.read(vendorMarketplaceListParamsProvider.notifier);
      n.state = ref
          .read(vendorMarketplaceListParamsProvider)
          .copyWith(
            page: 1,
            orderNumber: _orderNoMp.text.trim(),
            status: _statusMp ?? '',
          );
    } else {
      final n = ref.read(vendorManualListParamsProvider.notifier);
      n.state = ref
          .read(vendorManualListParamsProvider)
          .copyWith(
            page: 1,
            orderNumber: _orderNoMan.text.trim(),
            status: _statusMan ?? '',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusesAsync = ref.watch(vendorOrderStatusesProvider);

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
          'Orders & billing',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AllColor.loginButtomColor,
          unselectedLabelColor: AllColor.grey500,
          indicatorColor: AllColor.loginButtomColor,
          tabs: const [
            Tab(text: 'Marketplace'),
            Tab(text: 'Walk-in'),
            Tab(text: 'Wallet'),
            Tab(text: 'Refunds'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MarketplaceTab(
            orderNoController: _orderNoMp,
            statusValue: _statusMp,
            onStatusChanged: (v) => setState(() => _statusMp = v),
            statusesAsync: statusesAsync,
            onPickDate: (from) => _pickDate(isFrom: from, marketplace: true),
            onClearDates: () => _clearDates(true),
            onApply: () => _applySearch(true),
          ),
          _WalkInTab(
            orderNoController: _orderNoMan,
            statusValue: _statusMan,
            onStatusChanged: (v) => setState(() => _statusMan = v),
            statusesAsync: statusesAsync,
            onPickDate: (from) => _pickDate(isFrom: from, marketplace: false),
            onClearDates: () => _clearDates(false),
            onApply: () => _applySearch(false),
          ),
          const _WalletTab(),
          const VendorRefundsTab(),
        ],
      ),
    );
  }
}

class _MarketplaceTab extends ConsumerWidget {
  const _MarketplaceTab({
    required this.orderNoController,
    required this.statusValue,
    required this.onStatusChanged,
    required this.statusesAsync,
    required this.onPickDate,
    required this.onClearDates,
    required this.onApply,
  });

  final TextEditingController orderNoController;
  final String? statusValue;
  final ValueChanged<String?> onStatusChanged;
  final AsyncValue<VendorOrderStatusesPayload> statusesAsync;
  final void Function(bool from) onPickDate;
  final VoidCallback onClearDates;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(vendorMarketplaceListParamsProvider);
    final async = ref.watch(vendorMarketplaceOrdersProvider);

    return Column(
      children: [
        _FilterCard(
          orderNoController: orderNoController,
          statusValue: statusValue,
          onStatusChanged: onStatusChanged,
          statusesAsync: statusesAsync,
          fromLabel: params.fromDate ?? 'From',
          toLabel: params.toDate ?? 'To',
          onPickFrom: () => onPickDate(true),
          onPickTo: () => onPickDate(false),
          onClearDates: onClearDates,
          onApply: onApply,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vendorMarketplaceOrdersProvider);
              ref.invalidate(vendorOrderStatusesProvider);
            },
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 80.h),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      e.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 80.h),
                      Center(
                        child: Text(
                          'No line items in this range.',
                          style: TextStyle(
                            color: AllColor.grey500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                final groups = _groupMarketplaceLinesByOrder(page.items);
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                  itemCount: groups.length,
                  itemBuilder: (_, i) {
                    final lines = groups[i];
                    return _MarketplaceOrderGroupTile(
                      lines: lines,
                      onTap: () => context.push(
                        VendorMarketplaceOrderDetailScreen.routePath(
                          lines.first.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        _PaginationBar(
          current: params.page,
          lastPage: async.valueOrNull?.lastPage ?? 1,
          onPage: (p) {
            ref.read(vendorMarketplaceListParamsProvider.notifier).state = ref
                .read(vendorMarketplaceListParamsProvider)
                .copyWith(page: p);
          },
        ),
      ],
    );
  }
}

class _WalkInTab extends ConsumerWidget {
  const _WalkInTab({
    required this.orderNoController,
    required this.statusValue,
    required this.onStatusChanged,
    required this.statusesAsync,
    required this.onPickDate,
    required this.onClearDates,
    required this.onApply,
  });

  final TextEditingController orderNoController;
  final String? statusValue;
  final ValueChanged<String?> onStatusChanged;
  final AsyncValue<VendorOrderStatusesPayload> statusesAsync;
  final void Function(bool from) onPickDate;
  final VoidCallback onClearDates;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(vendorManualListParamsProvider);
    final async = ref.watch(vendorManualOrdersProvider);
    final fabBottom = MediaQuery.paddingOf(context).bottom + 88.h;

    return Stack(
      children: [
        Column(
          children: [
            _FilterCard(
              orderNoController: orderNoController,
              statusValue: statusValue,
              onStatusChanged: onStatusChanged,
              statusesAsync: statusesAsync,
              fromLabel: params.fromDate ?? 'From',
              toLabel: params.toDate ?? 'To',
              onPickFrom: () => onPickDate(true),
              onPickTo: () => onPickDate(false),
              onClearDates: onClearDates,
              onApply: onApply,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(vendorManualOrdersProvider);
                  ref.invalidate(vendorOrderStatusesProvider);
                },
                child: async.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 80.h),
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  data: (page) {
                    if (page.items.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          Center(
                            child: Text(
                              'No walk-in orders in this range.',
                              style: TextStyle(
                                color: AllColor.grey500,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                      itemCount: page.items.length,
                      itemBuilder: (_, i) {
                        final inv = page.items[i];
                        return _ManualTile(
                          invoice: inv,
                          onTap: () => context.push(
                            VendorManualOrderDetailScreen.routePath(inv.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            _PaginationBar(
              current: params.page,
              lastPage: async.valueOrNull?.lastPage ?? 1,
              onPage: (p) {
                ref.read(vendorManualListParamsProvider.notifier).state = ref
                    .read(vendorManualListParamsProvider)
                    .copyWith(page: p);
              },
            ),
          ],
        ),
        Positioned(
          right: 20.w,
          bottom: fabBottom,
          child: FloatingActionButton.extended(
            onPressed: () async {
              // `POST /api/vendor/manual-orders` — screen pops created invoice id.
              final newInvoiceId = await context.push<int?>(
                VendorCreateManualOrderScreen.routeName,
              );
              if (!context.mounted) return;
              if (newInvoiceId != null) {
                ref.invalidate(vendorManualOrdersProvider);
                if (newInvoiceId > 0) {
                  GlobalSnackbar.show(
                    context,
                    title: 'Created',
                    message: 'Walk-in order saved',
                    type: CustomSnackType.success,
                  );
                }
              }
            },
            backgroundColor: AllColor.loginButtomColor,
            icon: const Icon(Icons.add),
            label: const Text('New order'),
          ),
        ),
      ],
    );
  }
}

/// Payout form → `POST /vendor/wallet/payout`.
/// API expects `payment_method` ∈ allowed values and `payment_details` as `{ account, name, ... }`.
class _VendorPayoutRequestDialog extends StatefulWidget {
  const _VendorPayoutRequestDialog({this.walletBalance});

  /// When set, amount must be ≤ this (client-side check before API).
  final num? walletBalance;

  @override
  State<_VendorPayoutRequestDialog> createState() =>
      _VendorPayoutRequestDialogState();
}

class _VendorPayoutRequestDialogState
    extends State<_VendorPayoutRequestDialog> {
  static const _methodChoices = <({String value, String label})>[
    (value: 'bank_transfer', label: 'Bank transfer'),
    (value: 'mobile_money', label: 'Mobile money'),
    (value: 'paypal', label: 'PayPal'),
    (value: 'cash', label: 'Cash'),
  ];

  final _amount = TextEditingController();
  final _account = TextEditingController();
  final _holderName = TextEditingController();
  final _bankName = TextEditingController();
  final _note = TextEditingController();
  String _paymentMethod = _methodChoices.first.value;
  bool _busy = false;
  String? _error;

  InputDecoration _fieldDeco({required String label, String? hint}) {
    final orange = AllColor.loginButtomColor;
    final soft = AllColor.orange200;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AllColor.orange50.withValues(alpha: 0.35),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: soft, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: orange, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _account.dispose();
    _holderName.dispose();
    _bankName.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final a = _amount.text.trim();
    final acc = _account.text.trim();
    final name = _holderName.text.trim();
    if (a.isEmpty || acc.isEmpty || name.isEmpty) {
      setState(
        () => _error = 'Amount, account number, and account name are required.',
      );
      return;
    }
    final amtNum = num.tryParse(a.replaceAll(',', ''));
    if (amtNum == null) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    if (amtNum <= 0) {
      setState(() => _error = 'Amount must be greater than zero.');
      return;
    }
    final maxBal = widget.walletBalance;
    if (maxBal != null && amtNum > maxBal) {
      setState(
        () => _error =
            'Insufficient wallet balance. Available: $maxBal · Requested: $amtNum',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await VendorOrderApi.instance.requestWalletPayout(
        amount: a,
        paymentMethod: _paymentMethod,
        account: acc,
        accountHolderName: name,
        bankName: _bankName.text.trim().isEmpty ? null : _bankName.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      title: Text(
        'Request payout',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AllColor.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AllColor.red.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: AllColor.red,
                      fontSize: 12.sp,
                      height: 1.35,
                    ),
                  ),
                ),
              TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _fieldDeco(label: 'Amount', hint: 'e.g. 2000'),
              ),
              if (widget.walletBalance != null) ...[
                SizedBox(height: 6.h),
                Text(
                  'Available balance: ${widget.walletBalance}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              InputDecorator(
                decoration: _fieldDeco(label: 'Payment method'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _paymentMethod,
                    isExpanded: true,
                    items: _methodChoices
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.value,
                            child: Text(e.label),
                          ),
                        )
                        .toList(),
                    onChanged: _busy
                        ? null
                        : (v) {
                            if (v != null) {
                              setState(() => _paymentMethod = v);
                            }
                          },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _account,
                keyboardType: TextInputType.text,
                decoration: _fieldDeco(
                  label: 'Account / phone number',
                  hint: 'Number the payout should go to',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _holderName,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDeco(
                  label: 'Account name',
                  hint: 'Name on account or wallet',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _bankName,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDeco(
                  label: 'Bank name (optional)',
                  hint: 'For bank transfer',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: _fieldDeco(label: 'Note (optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AllColor.loginButtomColor,
          ),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AllColor.loginButtomColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: _busy
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

class _WalletTab extends ConsumerWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(vendorWalletOverviewProvider);
    final txParams = ref.watch(vendorWalletTxParamsProvider);
    final tx = ref.watch(vendorWalletTransactionsProvider);
    final payouts = ref.watch(vendorWalletPayoutsProvider);
    final payoutPage = ref.watch(vendorWalletPayoutsPageProvider);
    final payoutStatusFilter = ref.watch(
      vendorWalletPayoutStatusFilterProvider,
    );
    final txTypeFilter = ref.watch(vendorWalletTxTypeFilterProvider);
    final txStatusFilter = ref.watch(vendorWalletTxStatusFilterProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vendorWalletOverviewProvider);
        ref.invalidate(vendorWalletTransactionsProvider);
        ref.invalidate(vendorWalletPayoutsProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          overview.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
            data: (w) => Card(
              elevation: 0,
              color: AllColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet balance',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AllColor.grey500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            w.balanceLabel,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AllColor.black,
                            ),
                          ),
                          if (w.currency != null &&
                              w.currency!.trim().isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              w.currency!.trim(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AllColor.grey500,
                              ),
                            ),
                          ],
                          if (w.raw.containsKey('total_credited') ||
                              w.raw.containsKey('total_debited')) ...[
                            SizedBox(height: 6.h),
                            Text(
                              'Credited ${w.creditedLabel} · Debited ${w.debitedLabel}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AllColor.grey500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => _VendorPayoutRequestDialog(
                            walletBalance: w.balanceNumeric,
                          ),
                        );
                        if (ok == true && context.mounted) {
                          ref.invalidate(vendorWalletOverviewProvider);
                          ref.invalidate(vendorWalletTransactionsProvider);
                          ref.invalidate(vendorWalletPayoutsProvider);
                          GlobalSnackbar.show(
                            context,
                            title: 'Success',
                            message: 'Payout request submitted',
                            type: CustomSnackType.success,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AllColor.loginButtomColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                      ),
                      child: Text(
                        'Request',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Payout requests',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String?>(
            initialValue: payoutStatusFilter,
            decoration: InputDecoration(
              labelText: 'Payout status',
              filled: true,
              fillColor: AllColor.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            items: const [
              DropdownMenuItem<String?>(value: null, child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (v) {
              ref.read(vendorWalletPayoutStatusFilterProvider.notifier).state =
                  v;
              ref.read(vendorWalletPayoutsPageProvider.notifier).state = 1;
            },
          ),
          SizedBox(height: 8.h),
          payouts.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(e.toString()),
            data: (payoutPageData) {
              if (payoutPageData.items.isEmpty) {
                return Text(
                  'No payout requests.',
                  style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
                );
              }
              return Column(
                children: [
                  ...payoutPageData.items.map(
                    (row) => Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: ListTile(
                        title: Text(
                          '${row.amount} · ${row.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        subtitle: Text(
                          '${row.paymentMethod}'
                          '${row.createdAt != null ? '\n${row.createdAt}' : ''}'
                          '${row.note != null && row.note!.isNotEmpty ? '\n${row.note}' : ''}',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: payoutPage <= 1
                            ? null
                            : () {
                                ref
                                        .read(
                                          vendorWalletPayoutsPageProvider
                                              .notifier,
                                        )
                                        .state =
                                    payoutPage - 1;
                              },
                        child: const Text('Prev'),
                      ),
                      Text('$payoutPage / ${payoutPageData.lastPage}'),
                      TextButton(
                        onPressed: payoutPage >= payoutPageData.lastPage
                            ? null
                            : () {
                                ref
                                        .read(
                                          vendorWalletPayoutsPageProvider
                                              .notifier,
                                        )
                                        .state =
                                    payoutPage + 1;
                              },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(now.year + 1),
                      initialDate: now,
                    );
                    if (d == null) return;
                    final f =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    ref.read(vendorWalletTxParamsProvider.notifier).state = ref
                        .read(vendorWalletTxParamsProvider)
                        .copyWith(page: 1, fromDate: f);
                  },
                  child: Text(txParams.fromDate ?? 'Tx from'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(now.year + 1),
                      initialDate: now,
                    );
                    if (d == null) return;
                    final f =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    ref.read(vendorWalletTxParamsProvider.notifier).state = ref
                        .read(vendorWalletTxParamsProvider)
                        .copyWith(page: 1, toDate: f);
                  },
                  child: Text(txParams.toDate ?? 'Tx to'),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(vendorWalletTxParamsProvider.notifier).state =
                      const VendorOrderListParams(page: 1);
                  ref.read(vendorWalletTxTypeFilterProvider.notifier).state =
                      null;
                  ref.read(vendorWalletTxStatusFilterProvider.notifier).state =
                      null;
                },
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: txTypeFilter,
                  decoration: InputDecoration(
                    labelText: 'Tx type',
                    filled: true,
                    fillColor: AllColor.white,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('Any')),
                    DropdownMenuItem(value: 'credit', child: Text('credit')),
                    DropdownMenuItem(value: 'debit', child: Text('debit')),
                    DropdownMenuItem(value: 'refund', child: Text('refund')),
                    DropdownMenuItem(
                      value: 'withdraw',
                      child: Text('withdraw'),
                    ),
                    DropdownMenuItem(value: 'topup', child: Text('topup')),
                    DropdownMenuItem(
                      value: 'order_payment',
                      child: Text('order_payment'),
                    ),
                  ],
                  onChanged: (v) {
                    ref.read(vendorWalletTxTypeFilterProvider.notifier).state =
                        v;
                    ref.read(vendorWalletTxParamsProvider.notifier).state = ref
                        .read(vendorWalletTxParamsProvider)
                        .copyWith(page: 1);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: txStatusFilter,
                  decoration: InputDecoration(
                    labelText: 'Tx status',
                    filled: true,
                    fillColor: AllColor.white,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('Any')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('completed'),
                    ),
                    DropdownMenuItem(
                      value: 'processing',
                      child: Text('processing'),
                    ),
                  ],
                  onChanged: (v) {
                    ref
                            .read(vendorWalletTxStatusFilterProvider.notifier)
                            .state =
                        v;
                    ref.read(vendorWalletTxParamsProvider.notifier).state = ref
                        .read(vendorWalletTxParamsProvider)
                        .copyWith(page: 1);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Transactions',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          tx.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(e.toString()),
            data: (page) {
              if (page.items.isEmpty) {
                return Text(
                  'No transactions.',
                  style: TextStyle(color: AllColor.grey500, fontSize: 14.sp),
                );
              }
              return Column(
                children: [
                  ...page.items.map(
                    (t) => Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: ListTile(
                        title: Text(t.type),
                        subtitle: Text(
                          '${t.transactionId != null && t.transactionId!.isNotEmpty ? '${t.transactionId!} · ' : ''}'
                          '${t.amount} · ${t.status}'
                          '${t.createdAt != null ? '\n${t.createdAt}' : ''}'
                          '${t.description != null && t.description!.isNotEmpty ? '\n${t.description}' : ''}',
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: txParams.page <= 1
                            ? null
                            : () {
                                ref
                                    .read(vendorWalletTxParamsProvider.notifier)
                                    .state = txParams.copyWith(
                                  page: txParams.page - 1,
                                );
                              },
                        child: const Text('Prev'),
                      ),
                      Text('${txParams.page} / ${page.lastPage}'),
                      TextButton(
                        onPressed: txParams.page >= page.lastPage
                            ? null
                            : () {
                                ref
                                    .read(vendorWalletTxParamsProvider.notifier)
                                    .state = txParams.copyWith(
                                  page: txParams.page + 1,
                                );
                              },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.orderNoController,
    required this.statusValue,
    required this.onStatusChanged,
    required this.statusesAsync,
    required this.fromLabel,
    required this.toLabel,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClearDates,
    required this.onApply,
  });

  final TextEditingController orderNoController;
  final String? statusValue;
  final ValueChanged<String?> onStatusChanged;
  final AsyncValue<VendorOrderStatusesPayload> statusesAsync;
  final String fromLabel;
  final String toLabel;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onClearDates;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Material(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: orderNoController,
                decoration: const InputDecoration(
                  labelText: 'Order #',
                  isDense: true,
                ),
              ),
              SizedBox(height: 8.h),
              statusesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (st) {
                  if (st.statuses.isEmpty) return const SizedBox.shrink();
                  return DropdownButtonFormField<String?>(
                    initialValue: statusValue,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Any'),
                      ),
                      ...st.statuses.map(
                        (s) =>
                            DropdownMenuItem<String?>(value: s, child: Text(s)),
                      ),
                    ],
                    onChanged: onStatusChanged,
                  );
                },
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickFrom,
                      child: Text(fromLabel, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickTo,
                      child: Text(toLabel, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  IconButton(
                    onPressed: onClearDates,
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              FilledButton(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                ),
                child: const Text('Apply filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.current,
    required this.lastPage,
    required this.onPage,
  });

  final int current;
  final int lastPage;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: current <= 1 ? null : () => onPage(current - 1),
                child: const Text('Previous'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text('$current / $lastPage'),
              ),
              TextButton(
                onPressed: current >= lastPage
                    ? null
                    : () => onPage(current + 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same customer fields as detail / API: line `cus_name`, then invoice `cus_name`.
String _marketplaceCustomerLabel(VendorMarketplaceLine line) {
  final a = line.lineCustomerName?.trim();
  if (a != null && a.isNotEmpty) return a;
  final b = line.invoice.cusName?.trim();
  if (b != null && b.isNotEmpty) return b;
  return 'Customer';
}

String _marketplaceGroupCustomer(Iterable<VendorMarketplaceLine> lines) {
  for (final l in lines) {
    final c = _marketplaceCustomerLabel(l);
    if (c != 'Customer') return c;
  }
  return 'Customer';
}

/// One card per marketplace order (invoice): same order number is not repeated per line.
List<List<VendorMarketplaceLine>> _groupMarketplaceLinesByOrder(
  List<VendorMarketplaceLine> items,
) {
  final map = <String, List<VendorMarketplaceLine>>{};
  for (final line in items) {
    final on = line.invoice.orderNumber.trim();
    final key = on.isNotEmpty ? on : 'inv_${line.invoice.id}';
    map.putIfAbsent(key, () => []).add(line);
  }
  return map.values.toList();
}

class _MarketplaceOrderGroupTile extends StatelessWidget {
  const _MarketplaceOrderGroupTile({
    required this.lines,
    required this.onTap,
  });

  final List<VendorMarketplaceLine> lines;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final first = lines.first;
    final orderNo = first.invoice.orderNumber.trim().isEmpty
        ? 'INV-${first.invoice.id}'
        : first.invoice.orderNumber;
    final totalQty = lines.fold<int>(0, (s, l) => s + l.quantity);
    final customer = _marketplaceGroupCustomer(lines);

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        onTap: onTap,
        title: Text(
          customer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Order Number: $orderNo\n'
          '${lines.length} product(s) · $totalQty qty',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ManualTile extends StatelessWidget {
  const _ManualTile({required this.invoice, required this.onTap});

  final VendorManualOrderInvoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        onTap: onTap,
        title: Text(
          invoice.orderNumber.isEmpty ? '#${invoice.id}' : invoice.orderNumber,
        ),
        subtitle: Text(
          '${invoice.customerName ?? "Customer"}\n'
          'Payable ${invoice.summary.payable} · ${invoice.status}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
