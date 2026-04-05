import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/affiliate/data/affiliate_data.dart';
import 'package:market_jango/features/affiliate/model/affiliate_model.dart';

class DriverPromotionScreen extends ConsumerWidget {
  const DriverPromotionScreen({super.key, required this.driverId});

  static const String routeName = '/driverPromotion';
  final int driverId;

  /// Base URL for building affiliate link (GET api/affiliate/links is used with token).
  static String _baseUrl() {
    try {
      final base = Uri.parse(CommonAPIController.affiliateLinks);
      return '${base.scheme}://${base.host}${base.port != 80 && base.port != 443 ? ':${base.port}' : ''}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(affiliateLinksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios, size: 20.r, color: AllColor.black),
          ),
        ),
        title: Text(
          'Promotions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: linksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AllColor.grey500),
                SizedBox(height: 16.h),
                Text(
                  e.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
                ),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(affiliateLinksProvider);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllColor.loginButtomColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_outlined, size: 56.sp,
                      color: AllColor.grey300),
                  SizedBox(height: 16.h),
                  Text(
                    'No promotions yet',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'You have no affiliate links yet.',
                    style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final link = items[index];
              return _DriverLinkTile(
                link: link,
                onTap: () => _openLinkDetailSheet(context, link),
              );
            },
          );
        },
      ),
    );
  }

  void _openLinkDetailSheet(BuildContext context, AffiliateLinkModel link) {
    final fullUrl = '${_baseUrl()}/affiliate/${link.linkCode}';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LinkDetailSheet(
        link: link,
        fullUrl: fullUrl,
        onCopy: () {
          if (fullUrl.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: fullUrl));
            GlobalSnackbar.show(
              context,
              title: 'Copied',
              message: 'Link copied to clipboard',
              type: CustomSnackType.success,
            );
          }
        },
      ),
    );
  }
}

class _DriverLinkTile extends StatelessWidget {
  final AffiliateLinkModel link;
  final VoidCallback onTap;

  const _DriverLinkTile({required this.link, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = link.status == 'active';

    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AllColor.orange50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.link, size: 22.r,
                    color: AllColor.loginButtomColor),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.displayName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (link.createdAt != null && link.createdAt!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        link.createdAt!,
                        style: TextStyle(
                            fontSize: 12.sp, color: AllColor.grey500),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      '${link.clicks} clicks · ${link.conversions} conversions',
                      style: TextStyle(
                          fontSize: 11.sp, color: AllColor.grey500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? AllColor.green.withOpacity(0.15)
                      : AllColor.grey200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AllColor.green : AllColor.grey500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right, color: AllColor.grey500, size: 22.r),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet: link details + copy link (for GET api/affiliate/links items).
class _LinkDetailSheet extends StatelessWidget {
  final AffiliateLinkModel link;
  final String fullUrl;
  final VoidCallback onCopy;

  const _LinkDetailSheet({
    required this.link,
    required this.fullUrl,
    required this.onCopy,
  });

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.grey500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, color: AllColor.black),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24.h;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPadding),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AllColor.grey200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AllColor.grey100.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AllColor.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Name', link.displayName),
                  if (link.description != null &&
                      link.description!.trim().isNotEmpty)
                    _row('Description', link.description!),
                  if (link.destinationUrl != null &&
                      link.destinationUrl!.trim().isNotEmpty)
                    _row('Destination URL', link.destinationUrl!),
                  _row('Link code', link.linkCode),
                  _row('Clicks', '${link.clicks}'),
                  _row('Conversions', '${link.conversions}'),
                  _row('Conversion rate', '${link.conversionRate}%'),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: link.status == 'active'
                              ? AllColor.green.withOpacity(0.15)
                              : AllColor.grey200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          link.status,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: link.status == 'active'
                                ? AllColor.green
                                : AllColor.grey500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            if (fullUrl.isNotEmpty) ...[
              Text(
                'Share link',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AllColor.grey500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AllColor.grey100.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AllColor.grey200),
                ),
                child: SelectableText(
                  fullUrl,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.black87,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: Icon(Icons.copy_rounded, size: 18.r),
                  label: const Text('Copy link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.loginButtomColor,
                    side: BorderSide(color: AllColor.loginButtomColor),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
