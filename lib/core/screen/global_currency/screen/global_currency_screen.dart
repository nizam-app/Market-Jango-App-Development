import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/global_currency/data/currency_data.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/screen/profile_screen/logic/user_data_update_riverpod.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';

class GlobalCurrencyScreen extends ConsumerWidget {
  const GlobalCurrencyScreen({super.key});
  static const String routeName = '/currency';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCurrencies = ref.watch(currenciesProvider);
    final userId = ref.watch(getUserIdProvider).value ?? '';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tuppertextandbackbutton(
              screenName: ref.t(BKeys.currency, fallback: 'Currency'),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: asyncCurrencies.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e'),
                ),
                data: (currencies) {
                  if (currencies.isEmpty) {
                    return const Center(child: Text('No currencies found'));
                  }
                  return ListView.separated(
                    itemCount: currencies.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, i) {
                      final c = currencies[i];
                      return _CurrencyTile(
                        code: c.code,
                        name: c.name,
                        symbol: c.symbol,
                        onTap: () => _onCurrencySelected(
                          context,
                          ref,
                          userId: userId,
                          code: c.code,
                          name: c.name,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _onCurrencySelected(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String code,
    required String name,
  }) async {
    final userTypeAsync = await ref.read(getUserTypeProvider.future);
    final userType = userTypeAsync ?? 'buyer';

    final notifier = ref.read(updateUserProvider.notifier);
    final success = await notifier.updateUser(
      userType: userType,
      currency: code,
    );

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(userProvider(userId));
      GlobalSnackbar.show(
        context,
        title: 'Success',
        message: 'Currency updated to $name ($code)',
        type: CustomSnackType.success,
      );
      Navigator.of(context).pop();
    } else {
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: 'Failed to update currency',
        type: CustomSnackType.error,
      );
    }
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.code,
    required this.name,
    required this.symbol,
    required this.onTap,
  });

  final String code;
  final String name;
  final String symbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AllColor.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AllColor.black,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AllColor.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AllColor.grey,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
