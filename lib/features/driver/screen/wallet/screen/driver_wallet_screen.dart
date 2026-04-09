import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/driver/screen/wallet/data/driver_wallet_api.dart';
import 'package:market_jango/features/driver/screen/wallet/provider/driver_wallet_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// Driver wallet UI — `doc/details.md` (wallet, transactions, payout, payouts).
class DriverWalletScreen extends ConsumerWidget {
  const DriverWalletScreen({super.key});

  static const routeName = '/driver/wallet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(driverWalletOverviewProvider);
    final txParams = ref.watch(driverWalletTxParamsProvider);
    final tx = ref.watch(driverWalletTransactionsProvider);
    final payouts = ref.watch(driverWalletPayoutsProvider);
    final payoutPage = ref.watch(driverWalletPayoutsPageProvider);
    final payoutStatusFilter = ref.watch(driverWalletPayoutStatusFilterProvider);
    final txTypeFilter = ref.watch(driverWalletTxTypeFilterProvider);
    final txStatusFilter = ref.watch(driverWalletTxStatusFilterProvider);

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
          'My wallet',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(driverWalletOverviewProvider);
          ref.invalidate(driverWalletTransactionsProvider);
          ref.invalidate(driverWalletPayoutsProvider);
          await Future.wait([
            ref.read(driverWalletOverviewProvider.future),
            ref.read(driverWalletTransactionsProvider.future),
            ref.read(driverWalletPayoutsProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AllColor.orange50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AllColor.orange200),
              ),
              child: Text(
                'Earnings are credited by the platform. Self-service top-up is not available for drivers.',
                style: TextStyle(fontSize: 12.sp, height: 1.35),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AllColor.grey100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Refund requests are handled in buyer/vendor flows — there are no driver refund APIs.',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.35,
                  color: AllColor.grey500,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            overview.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
              data: (w) => Card(
                elevation: 0,
                color: AllColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: AllColor.grey200),
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
                              'Balance',
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
                            builder: (_) => _DriverPayoutDialog(
                              walletBalance: w.balanceNumeric,
                            ),
                          );
                          if (ok == true && context.mounted) {
                            ref.invalidate(driverWalletOverviewProvider);
                            ref.invalidate(driverWalletTransactionsProvider);
                            ref.invalidate(driverWalletPayoutsProvider);
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
                        ),
                        child: Text(
                          'Withdraw',
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
            SizedBox(height: 20.h),
            Text(
              'Payout requests',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String?>(
              value: payoutStatusFilter,
              decoration: InputDecoration(
                labelText: 'Status',
                filled: true,
                fillColor: AllColor.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'processing', child: Text('Processing')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (v) {
                ref.read(driverWalletPayoutStatusFilterProvider.notifier).state =
                    v;
                ref.read(driverWalletPayoutsPageProvider.notifier).state = 1;
              },
            ),
            SizedBox(height: 8.h),
            payouts.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(e.toString()),
              data: (pp) {
                if (pp.items.isEmpty) {
                  return Text(
                    'No payout requests.',
                    style: TextStyle(color: AllColor.grey500, fontSize: 13.sp),
                  );
                }
                return Column(
                  children: [
                    ...pp.items.map(
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
                                          .read(driverWalletPayoutsPageProvider
                                              .notifier)
                                          .state =
                                      payoutPage - 1;
                                },
                          child: const Text('Prev'),
                        ),
                        Text('$payoutPage / ${pp.lastPage}'),
                        TextButton(
                          onPressed: payoutPage >= pp.lastPage
                              ? null
                              : () {
                                  ref
                                          .read(driverWalletPayoutsPageProvider
                                              .notifier)
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
            SizedBox(height: 20.h),
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
                      ref.read(driverWalletTxParamsProvider.notifier).state =
                          ref.read(driverWalletTxParamsProvider).copyWith(
                                page: 1,
                                fromDate: f,
                              );
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
                      ref.read(driverWalletTxParamsProvider.notifier).state =
                          ref.read(driverWalletTxParamsProvider).copyWith(
                                page: 1,
                                toDate: f,
                              );
                    },
                    child: Text(txParams.toDate ?? 'Tx to'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(driverWalletTxParamsProvider.notifier).state =
                        const DriverWalletTxParams(page: 1);
                    ref.read(driverWalletTxTypeFilterProvider.notifier).state =
                        null;
                    ref.read(driverWalletTxStatusFilterProvider.notifier).state =
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
                    value: txTypeFilter,
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
                      ref.read(driverWalletTxTypeFilterProvider.notifier).state =
                          v;
                      ref.read(driverWalletTxParamsProvider.notifier).state =
                          ref.read(driverWalletTxParamsProvider).copyWith(
                                page: 1,
                              );
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: txStatusFilter,
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
                          .read(driverWalletTxStatusFilterProvider.notifier)
                          .state = v;
                      ref.read(driverWalletTxParamsProvider.notifier).state =
                          ref.read(driverWalletTxParamsProvider).copyWith(
                                page: 1,
                              );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
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
                                          .read(driverWalletTxParamsProvider
                                              .notifier)
                                          .state =
                                      txParams.copyWith(
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
                                          .read(driverWalletTxParamsProvider
                                              .notifier)
                                          .state =
                                      txParams.copyWith(
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
      ),
    );
  }
}

class _DriverPayoutDialog extends StatefulWidget {
  const _DriverPayoutDialog({this.walletBalance});

  final num? walletBalance;

  @override
  State<_DriverPayoutDialog> createState() => _DriverPayoutDialogState();
}

class _DriverPayoutDialogState extends State<_DriverPayoutDialog> {
  static const _methods = <({String value, String label})>[
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
  String _method = _methods.first.value;
  bool _busy = false;
  String? _error;

  InputDecoration _deco(String label, [String? hint]) {
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
        () => _error = 'Amount, account, and account name are required.',
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
            'Insufficient balance. Available: $maxBal · Requested: $amtNum',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await DriverWalletApi.instance.requestPayout(
        amount: a,
        paymentMethod: _method,
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
      title: Text(
        'Request withdrawal',
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
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AllColor.red, fontSize: 12.sp),
                  ),
                ),
              TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _deco('Amount', 'e.g. 100'),
              ),
              if (widget.walletBalance != null) ...[
                SizedBox(height: 6.h),
                Text(
                  'Available: ${widget.walletBalance}',
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                ),
              ],
              SizedBox(height: 12.h),
              InputDecorator(
                decoration: _deco('Payment method'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _method,
                    isExpanded: true,
                    items: _methods
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.label),
                          ),
                        )
                        .toList(),
                    onChanged: _busy
                        ? null
                        : (v) {
                            if (v != null) setState(() => _method = v);
                          },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _account,
                decoration: _deco('Account / phone', 'Payout destination'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _holderName,
                textCapitalization: TextCapitalization.words,
                decoration: _deco('Account name', 'Name on account'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _bankName,
                decoration: _deco('Bank name (optional)', null),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: _deco('Note (optional)', null),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AllColor.loginButtomColor,
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
