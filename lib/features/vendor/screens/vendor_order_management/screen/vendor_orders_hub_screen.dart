import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/provider/vendor_orders_provider.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

import 'vendor_create_manual_order_screen.dart';
import 'vendor_manual_order_detail_screen.dart';
import 'vendor_marketplace_order_detail_screen.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderNoMp.dispose();
    _orderNoMan.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom, required bool marketplace}) async {
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
      n.state = ref.read(vendorMarketplaceListParamsProvider).copyWith(
            page: 1,
            clearDates: true,
          );
    } else {
      final n = ref.read(vendorManualListParamsProvider.notifier);
      n.state = ref.read(vendorManualListParamsProvider).copyWith(
            page: 1,
            clearDates: true,
          );
    }
  }

  void _applySearch(bool marketplace) {
    if (marketplace) {
      final n = ref.read(vendorMarketplaceListParamsProvider.notifier);
      n.state = ref.read(vendorMarketplaceListParamsProvider).copyWith(
            page: 1,
            orderNumber: _orderNoMp.text.trim(),
            status: _statusMp ?? '',
          );
    } else {
      final n = ref.read(vendorManualListParamsProvider.notifier);
      n.state = ref.read(vendorManualListParamsProvider).copyWith(
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
                          style: TextStyle(color: AllColor.grey500, fontSize: 14.sp),
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
                    final line = page.items[i];
                    return _MarketplaceTile(
                      line: line,
                      onTap: () => context.push(
                        VendorMarketplaceOrderDetailScreen.routePath(line.id),
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
            ref.read(vendorMarketplaceListParamsProvider.notifier).state =
                ref.read(vendorMarketplaceListParamsProvider).copyWith(page: p);
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
                ref.read(vendorManualListParamsProvider.notifier).state =
                    ref.read(vendorManualListParamsProvider).copyWith(page: p);
              },
            ),
          ],
        ),
        Positioned(
          right: 20.w,
          bottom: 90.h,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final ok = await context.push<bool>(
                VendorCreateManualOrderScreen.routeName,
              );
              if (!context.mounted) return;
              if (ok == true) {
                ref.invalidate(vendorManualOrdersProvider);
                GlobalSnackbar.show(
                  context,
                  title: 'Created',
                  message: 'Walk-in order saved',
                  type: CustomSnackType.success,
                );
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

class _WalletTab extends ConsumerWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(vendorWalletOverviewProvider);
    final txParams = ref.watch(vendorWalletTxParamsProvider);
    final tx = ref.watch(vendorWalletTransactionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vendorWalletOverviewProvider);
        ref.invalidate(vendorWalletTransactionsProvider);
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
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
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
                    ref.read(vendorWalletTxParamsProvider.notifier).state =
                        ref.read(vendorWalletTxParamsProvider).copyWith(
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
                    ref.read(vendorWalletTxParamsProvider.notifier).state =
                        ref.read(vendorWalletTxParamsProvider).copyWith(
                              page: 1,
                              toDate: f,
                            );
                  },
                  child: Text(txParams.toDate ?? 'Tx to'),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(vendorWalletTxParamsProvider.notifier).state =
                      const VendorOrderListParams(page: 1);
                },
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          SizedBox(height: 8.h),
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
                          '${t.amount} · ${t.status}'
                          '${t.createdAt != null ? '\n${t.createdAt}' : ''}',
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
                                        .state =
                                    txParams.copyWith(page: txParams.page - 1);
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
                                        .state =
                                    txParams.copyWith(page: txParams.page + 1);
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
                        (s) => DropdownMenuItem<String?>(
                          value: s,
                          child: Text(s),
                        ),
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
                  IconButton(onPressed: onClearDates, icon: const Icon(Icons.clear)),
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
                onPressed: current >= lastPage ? null : () => onPage(current + 1),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketplaceTile extends StatelessWidget {
  const _MarketplaceTile({required this.line, required this.onTap});

  final VendorMarketplaceLine line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        onTap: onTap,
        title: Text(
          line.product.name.isEmpty ? 'Product #${line.productId}' : line.product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Order Number: ${line.invoice.orderNumber}\n'
          'Number of products: ${line.quantity}',
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
        title: Text(invoice.orderNumber.isEmpty ? '#${invoice.id}' : invoice.orderNumber),
        subtitle: Text(
          '${invoice.customerName ?? "Customer"}\n'
          'Payable ${invoice.summary.payable} · ${invoice.status}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
