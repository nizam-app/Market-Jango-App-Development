import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/refunds/model/buyer_refund_models.dart';
import 'package:market_jango/features/buyer/screens/refunds/provider/buyer_refunds_provider.dart';
import 'package:market_jango/features/buyer/screens/refunds/screen/buyer_refund_detail_screen.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// My refund requests — `GET /api/buyer/refunds` (doc §E).
class BuyerRefundsScreen extends ConsumerWidget {
  const BuyerRefundsScreen({super.key});

  static const routeName = '/buyer/refunds';

  static const _statusChoices = <String?>[
    null,
    'pending',
    'approved',
    'rejected',
  ];

  String _statusLabel(String? s) {
    if (s == null) return 'All statuses';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(buyerRefundsPageProvider);
    final statusFilter = ref.watch(buyerRefundsStatusFilterProvider);
    final async = ref.watch(buyerRefundsListProvider);

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
          'My refunds',
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
          ref.invalidate(buyerRefundsListProvider);
          await ref.read(buyerRefundsListProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          children: [
            DropdownButtonFormField<String?>(
              value: statusFilter,
              decoration: InputDecoration(
                labelText: 'Status',
                filled: true,
                fillColor: AllColor.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              items: _statusChoices
                  .map(
                    (v) => DropdownMenuItem<String?>(
                      value: v,
                      child: Text(_statusLabel(v)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                ref.read(buyerRefundsStatusFilterProvider.notifier).state = v;
                ref.read(buyerRefundsPageProvider.notifier).state = 1;
              },
            ),
            SizedBox(height: 16.h),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(e.toString()),
              data: (payload) {
                final p = payload.refunds;
                if (p.items.isEmpty) {
                  return Text(
                    'No refund requests yet.',
                    style: TextStyle(color: AllColor.grey500, fontSize: 14.sp),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...p.items.map(
                      (r) => _RefundTile(
                        item: r,
                        onTap: () => context.push(
                          BuyerRefundDetailScreen.routeName,
                          extra: r.id,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: page <= 1
                              ? null
                              : () {
                                  ref.read(buyerRefundsPageProvider.notifier).state =
                                      page - 1;
                                },
                          child: const Text('Prev'),
                        ),
                        Text('$page / ${p.lastPage}'),
                        TextButton(
                          onPressed: page >= p.lastPage
                              ? null
                              : () {
                                  ref.read(buyerRefundsPageProvider.notifier).state =
                                      page + 1;
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

class _RefundTile extends StatelessWidget {
  const _RefundTile({required this.item, required this.onTap});

  final BuyerRefundListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AllColor.grey200),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          item.productName.isNotEmpty ? item.productName : 'Refund #${item.id}',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
        ),
        subtitle: Text(
          '${item.status} · ${item.amount}\n'
          '${item.orderNumber.isNotEmpty ? 'Order ${item.orderNumber}\n' : ''}'
          '${item.reason}',
          style: TextStyle(fontSize: 12.sp, height: 1.35),
        ),
        trailing: Icon(Icons.chevron_right, color: AllColor.grey500),
      ),
    );
  }
}
