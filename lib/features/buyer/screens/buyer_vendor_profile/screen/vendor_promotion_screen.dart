import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/vendor_affiliate_links_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/vendor_affiliate_link_model.dart';

class VendorPromotionScreen extends ConsumerWidget {
  const VendorPromotionScreen({super.key, required this.vendorId});

  static const String routeName = '/vendorPromotion';
  final int vendorId;

  /// Opens the first promotion link (if it has a URL) and shows only the link-create popup.
  /// Call this from vendor profile instead of navigating to the full promotion screen.
  static Future<void> showLinkCreatePopup(
    BuildContext context,
    WidgetRef ref,
    int vendorId,
  ) async {
    try {
      final links = await ref.read(vendorAffiliateLinksProvider(vendorId).future);
      if (links.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No promotions yet')),
          );
        }
        return;
      }
      final firstLink = links.first;
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _ReferralFormSheet(
          vendorId: vendorId,
          link: firstLink,
          onSuccess: (response) {
            Navigator.pop(ctx);
            _showReferralGeneratedDialog(context, response);
          },
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(vendorAffiliateLinksProvider(vendorId));

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
                  onPressed: () => ref.invalidate(vendorAffiliateLinksProvider(vendorId)),
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
                  Icon(Icons.campaign_outlined, size: 56.sp, color: AllColor.grey300),
                  SizedBox(height: 16.h),
                  Text(
                    'No promotions yet',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AllColor.black),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'This vendor has no affiliate links.',
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
              return _LinkTile(
                link: link,
                onTap: () => _openReferralForm(context, ref, link),
              );
            },
          );
        },
      ),
    );
  }

  void _openReferralForm(
    BuildContext context,
    WidgetRef ref,
    VendorAffiliateLinkModel link,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReferralFormSheet(
        vendorId: vendorId,
        link: link,
        onSuccess: (response) {
          Navigator.pop(ctx);
          _showReferralGeneratedDialog(context, response);
        },
      ),
    );
  }

  static void _showReferralGeneratedDialog(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    final message = response['message']?.toString() ?? 'Referral link generated';
    final data = response['data'] as Map<String, dynamic>?;
    final referralLink = data?['full_url']?.toString() ?? data?['referral_url']?.toString() ?? '';
    final deepLink = data?['deep_link']?.toString() ?? data?['referral_url']?.toString() ?? '';

    showDialog<void>(
      context: context,
      builder: (ctx) => _ReferralGeneratedDialog(
        message: message,
        referralLink: referralLink,
        deepLink: deepLink,
        onCopyReferralLink: () {
          if (referralLink.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: referralLink));
            GlobalSnackbar.show(
              context,
              title: 'Copied',
              message: 'Referral link copied to clipboard',
              type: CustomSnackType.success,
            );
          }
        },
        onCopyDeepLink: () {
          if (deepLink.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: deepLink));
            GlobalSnackbar.show(
              context,
              title: 'Copied',
              message: 'Deep link copied to clipboard',
              type: CustomSnackType.success,
            );
          }
        },
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final VendorAffiliateLinkModel link;
  final VoidCallback onTap;

  const _LinkTile({required this.link, required this.onTap});

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
                child: Icon(Icons.link, size: 22.r, color: AllColor.loginButtomColor),
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
                    if (link.createdAt != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        link.createdAt!,
                        style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? AllColor.green.withOpacity(0.15) : AllColor.grey200,
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

class _ReferralGeneratedDialog extends StatelessWidget {
  final String message;
  final String referralLink;
  final String deepLink;
  final VoidCallback onCopyReferralLink;
  final VoidCallback onCopyDeepLink;

  const _ReferralGeneratedDialog({
    required this.message,
    required this.referralLink,
    required this.deepLink,
    required this.onCopyReferralLink,
    required this.onCopyDeepLink,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AllColor.loginButtomColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.link_rounded, size: 28.r, color: AllColor.loginButtomColor),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AllColor.black,
                    ),
                  ),
                ),
              ],
            ),
            if (referralLink.isNotEmpty) ...[
              SizedBox(height: 20.h),
              Text(
                'Referral link',
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
                  referralLink,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.black87,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCopyReferralLink,
                  icon: Icon(Icons.copy_rounded, size: 18.r),
                  label: const Text('Copy referral link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.loginButtomColor,
                    side: BorderSide(color: AllColor.loginButtomColor),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
            if (deepLink.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'Deep link',
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
                  deepLink,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AllColor.black87,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCopyDeepLink,
                  icon: Icon(Icons.copy_rounded, size: 18.r),
                  label: const Text('Copy deep link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AllColor.loginButtomColor,
                    side: BorderSide(color: AllColor.loginButtomColor),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

class _ReferralFormSheet extends ConsumerStatefulWidget {
  final int vendorId;
  final VendorAffiliateLinkModel link;
  final void Function(Map<String, dynamic> response) onSuccess;

  const _ReferralFormSheet({
    required this.vendorId,
    required this.link,
    required this.onSuccess,
  });

  @override
  ConsumerState<_ReferralFormSheet> createState() => _ReferralFormSheetState();
}

class _ReferralFormSheetState extends ConsumerState<_ReferralFormSheet> {
  final _affiliateCodeController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _loading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _affiliateCodeController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final token = await ref.read(authTokenProvider.future);
      final code = _affiliateCodeController.text.trim();
      final url = _destinationController.text.trim();
      if (code.isEmpty || url.isEmpty) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            title: 'Required',
            message: 'Affiliate code and destination URL are required',
            type: CustomSnackType.error,
          );
        }
        return;
      }
      final response = await generateReferralLink(
        token,
        affiliateCode: code,
        vendorId: widget.vendorId,
        vendorAffiliateLinkId: widget.link.id,
        destinationUrl: url,
      );
      if (mounted) widget.onSuccess(response);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _detailRow(String label, String value) {
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
    final link = widget.link;

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
            // Link details (upper) – all fields from response
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
                  Text(
                    'Link details',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.grey500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _detailRow('Name', link.displayName),
                  if (link.description != null && link.description!.trim().isNotEmpty)
                    _detailRow('Description', link.description!),
                  if (link.destinationUrl != null && link.destinationUrl!.trim().isNotEmpty)
                    _detailRow('Destination URL', link.destinationUrl!),
                  if (link.customRate != null)
                    _detailRow('Custom rate', '${link.customRate}%'),
                  if (link.cookieDurationDays != null)
                    _detailRow('Cookie duration', '${link.cookieDurationDays} days'),
                  if (link.attributionModel != null && link.attributionModel!.trim().isNotEmpty)
                    _detailRow('Attribution model', link.attributionModel!),
                  if (link.expiresAt != null && link.expiresAt!.trim().isNotEmpty)
                    _detailRow('Expires at', link.expiresAt!),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                            color: link.status == 'active' ? AllColor.green : AllColor.grey500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Create referral link',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.black,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _affiliateCodeController,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                labelText: 'Affiliate code',
                hintText: 'AFF-XXXXXXXX',
                prefixIcon: Icon(Icons.tag, size: 22.r, color: AllColor.grey500),
                filled: true,
                fillColor: AllColor.grey100.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AllColor.grey200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AllColor.loginButtomColor, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: _destinationController,
              style: TextStyle(fontSize: 15.sp),
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Destination URL',
                hintText: 'https://yourapp.com/store/1',
                prefixIcon: Icon(Icons.link, size: 22.r, color: AllColor.grey500),
                filled: true,
                fillColor: AllColor.grey100.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AllColor.grey200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: AllColor.loginButtomColor, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
            SizedBox(height: 20.h),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                          activeColor: AllColor.loginButtomColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            'By using this referral link, you agree to follow our promotion rules and avoid any fake clicks, spam, or misleading claims.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AllColor.grey500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: (_loading || !_agreedToTerms) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _loading
                    ? SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_link_rounded, size: 22.r),
                          SizedBox(width: 8.w),
                          Text('Create referral link', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
