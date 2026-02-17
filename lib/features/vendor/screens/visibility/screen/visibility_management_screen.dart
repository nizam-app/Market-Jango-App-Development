import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
import 'package:market_jango/features/vendor/screens/visibility/data/visibility_data.dart';
import 'package:market_jango/features/vendor/screens/visibility/model/visibility_model.dart';
import 'package:market_jango/features/vendor/screens/visibility/screen/visibility_form_screen.dart';

class VisibilityManagementScreen extends ConsumerWidget {
  const VisibilityManagementScreen({super.key});

  static const String routeName = '/vendor_visibility_management';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(visibilityDashboardProvider);
    final notifier = ref.read(visibilityDashboardProvider.notifier);

    return Scaffold(
      backgroundColor: AllColor.white,
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          'Product Visibility',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: AllColor.grey),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => notifier.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (dashboard) {
            if (dashboard == null) {
              return const Center(child: Text('No visibility data'));
            }
            final usage = dashboard.usage;
            final list = dashboard.allVisibilities;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UsageCard(
                    used: usage.locationsUsed,
                    limit: usage.locationsLimit,
                    canAddMore: usage.canAddMore,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Visibility rules (${list.length})',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (list.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(
                        child: Text(
                          'No visibility rules yet. Tap + to add where your products are visible.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AllColor.grey500,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final v = list[index];
                        return _VisibilityCard(
                          visibility: v,
                          onEdit: () => context.push(
                            VisibilityFormScreen.routeName,
                            extra: v,
                          ),
                          onDelete: () => _confirmDelete(context, ref, v, notifier),
                        );
                      },
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: dashboardAsync.maybeWhen(
        data: (d) {
          if (d == null || !d.usage.canAddMore) return null;
          return FloatingActionButton(
            onPressed: () => context.push(VisibilityFormScreen.routeName),
            backgroundColor: AllColor.loginButtomColor,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
        orElse: () => null,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VisibilityModel v,
    VisibilityDashboardNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete visibility?'),
        content: Text(
          'Remove "${v.locationDisplay}" for ${v.product?.name ?? 'product #${v.productId}'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final token = await ref.read(authTokenProvider.future);
                await visibilityDelete(
                  token,
                  visibilityId: v.id,
                  onSuccess: () {
                    notifier.refresh();
                    if (context.mounted) {
                      GlobalSnackbar.show(
                        context,
                        title: 'Done',
                        message: 'Visibility deleted',
                        type: CustomSnackType.success,
                      );
                    }
                  },
                );
              } catch (e) {
                if (context.mounted) {
                  GlobalSnackbar.show(
                    context,
                    title: 'Error',
                    message: e.toString(),
                    type: CustomSnackType.error,
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: AllColor.red)),
          ),
        ],
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final int used;
  final int limit;
  final bool canAddMore;

  const _UsageCard({
    required this.used,
    required this.limit,
    required this.canAddMore,
  });

  @override
  Widget build(BuildContext context) {
    final limitStr = limit == 0 ? '∞' : limit.toString();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AllColor.orange50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColor.textBorderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility, color: AllColor.loginButtomColor, size: 28.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visibility usage',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$used / $limitStr locations',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AllColor.grey500,
                  ),
                ),
              ],
            ),
          ),
          if (!canAddMore && limit > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AllColor.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Limit reached',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AllColor.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  final VisibilityModel visibility;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VisibilityCard({
    required this.visibility,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final productName = visibility.product?.name ?? 'Product #${visibility.productId}';
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14.r, color: AllColor.grey500),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          visibility.locationDisplay,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AllColor.grey500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (!visibility.isActive)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 20.r, color: AllColor.loginButtomColor),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, size: 20.r, color: AllColor.red),
            ),
          ],
        ),
      ),
    );
  }
}
