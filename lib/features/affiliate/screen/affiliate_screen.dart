import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/affiliate/data/affiliate_data.dart';
import 'package:market_jango/features/affiliate/model/affiliate_model.dart';

class AffiliateScreen extends ConsumerWidget {
  const AffiliateScreen({super.key});

  static const String routeName = '/affiliate';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(affiliateLinksProvider);
    final statsAsync = ref.watch(affiliateStatisticsProvider);
    final linksNotifier = ref.read(affiliateLinksProvider.notifier);
    final statsNotifier = ref.read(affiliateStatisticsProvider.notifier);

    Future<void> onRefresh() async {
      await linksNotifier.refresh();
      await statsNotifier.refresh();
    }

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
          'Affiliate Links',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: linksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorSection(
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () {
              linksNotifier.refresh();
              statsNotifier.refresh();
            },
          ),
          data: (links) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statsAsync.when(
                    data: (stats) {
                      if (stats == null) return const SizedBox.shrink();
                      return _StatsCards(statistics: stats);
                    },
                    loading: () => SizedBox(height: 20.h),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your links',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColor.black,
                        ),
                      ),
                      Text(
                        '${links.length} link${links.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AllColor.grey500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (links.isEmpty)
                    _EmptyState(onAdd: () => _openAddSheet(context, ref)),
                  if (links.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: links.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final link = links[index];
                        return _LinkCard(
                          link: link,
                          baseUrl: _baseUrl(),
                          onCopy: () => _copyLink(context, link),
                          onEdit: () => _openEditSheet(context, ref, link, linksNotifier),
                          onDelete: () => _confirmDelete(
                            context,
                            ref,
                            link,
                            linksNotifier,
                            statsNotifier,
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 100.h),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        backgroundColor: AllColor.loginButtomColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New link',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  String _baseUrl() {
    try {
      final base = Uri.parse(CommonAPIController.affiliateLinks);
      return '${base.scheme}://${base.host}${base.port != 80 && base.port != 443 ? ':${base.port}' : ''}';
    } catch (_) {
      return 'https://example.com';
    }
  }

  void _copyLink(BuildContext context, AffiliateLinkModel link) {
    try {
      final base = _baseUrl();
      final url = '$base/affiliate/${link.linkCode}';
      Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Copied',
          message: 'Link copied to clipboard',
          type: CustomSnackType.success,
        );
      }
    } catch (_) {
      if (context.mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Error',
          message: 'Could not copy link',
          type: CustomSnackType.error,
        );
      }
    }
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddLinkSheet(
        onSaved: () {
          ref.read(affiliateLinksProvider.notifier).refresh();
          ref.read(affiliateStatisticsProvider.notifier).refresh();
        },
      ),
    );
  }

  void _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    AffiliateLinkModel link,
    AffiliateLinksNotifier notifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditLinkSheet(
        link: link,
        onSaved: () {
          notifier.refresh();
          ref.read(affiliateStatisticsProvider.notifier).refresh();
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AffiliateLinkModel link,
    AffiliateLinksNotifier linksNotifier,
    AffiliateStatisticsNotifier statsNotifier,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete link?'),
        content: Text(
          'Remove "${link.displayName}"? This cannot be undone.',
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
                await affiliateDelete(token, id: link.id);
                await linksNotifier.refresh();
                await statsNotifier.refresh();
                if (context.mounted) {
                  GlobalSnackbar.show(
                    context,
                    title: 'Deleted',
                    message: 'Affiliate link removed',
                    type: CustomSnackType.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  GlobalSnackbar.show(
                    context,
                    title: 'Error',
                    message: e.toString().replaceFirst('Exception: ', ''),
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

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSection({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AllColor.grey500),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
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
    );
  }
}

class _StatsCards extends StatelessWidget {
  final AffiliateStatisticsModel statistics;

  const _StatsCards({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.link,
                label: 'Links',
                value: '${statistics.activeLinks}/${statistics.totalLinks}',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.touch_app_outlined,
                label: 'Clicks',
                value: '${statistics.totalClicks}',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.percent,
                label: 'Conversions',
                value: '${statistics.totalConversions}',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.attach_money,
                label: 'Revenue',
                value: statistics.totalRevenue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.r, color: AllColor.loginButtomColor),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AllColor.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AllColor.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: 48.sp,
            color: AllColor.grey300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No affiliate links yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AllColor.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create a link to share and track clicks and conversions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
          ),
          SizedBox(height: 20.h),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: Icon(Icons.add, size: 18.sp),
            label: const Text('Create link'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AllColor.loginButtomColor,
              side: BorderSide(color: AllColor.loginButtomColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final AffiliateLinkModel link;
  final String baseUrl;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LinkCard({
    required this.link,
    required this.baseUrl,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = '$baseUrl/affiliate/${link.linkCode}';
    final isActive = link.status == 'active';

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AllColor.orange50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.link,
                  size: 20.r,
                  color: AllColor.loginButtomColor,
                ),
              ),
              SizedBox(width: 12.w),
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
                    SizedBox(height: 4.h),
                    Text(
                      link.linkCode,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.grey500,
                        fontFamily: 'monospace',
                      ),
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
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _MiniChip(
                icon: Icons.touch_app,
                label: '${link.clicks}',
              ),
              SizedBox(width: 12.w),
              _MiniChip(
                icon: Icons.trending_up,
                label: '${link.conversions}',
              ),
              SizedBox(width: 12.w),
              _MiniChip(
                icon: Icons.attach_money,
                label: link.revenue,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SelectableText(
            fullUrl,
            style: TextStyle(
              fontSize: 11.sp,
              color: AllColor.grey500,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: onCopy,
                icon: Icon(Icons.copy, size: 18.r),
                label: const Text('Copy'),
                style: TextButton.styleFrom(
                  foregroundColor: AllColor.loginButtomColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, size: 20.r),
                color: AllColor.grey500,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, size: 20.r),
                color: AllColor.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: AllColor.grey500),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog shown after creating a link – displays the shareable URL
// ---------------------------------------------------------------------------

class _CreatedLinkDialog extends StatelessWidget {
  final String fullUrl;
  final String linkCode;
  final VoidCallback onCopy;

  const _CreatedLinkDialog({
    required this.fullUrl,
    required this.linkCode,
    required this.onCopy,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link created',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColor.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Share this link to track clicks',
                        style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
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
                  fontSize: 13.sp,
                  color: AllColor.black87,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Code: $linkCode',
              style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onCopy();
                    },
                    icon: Icon(Icons.copy_rounded, size: 20.r),
                    label: const Text('Copy link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AllColor.loginButtomColor,
                      side: BorderSide(color: AllColor.loginButtomColor),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
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
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add link bottom sheet
// ---------------------------------------------------------------------------

class _AddLinkSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const _AddLinkSheet({required this.onSaved});

  @override
  ConsumerState<_AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends ConsumerState<_AddLinkSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();
  final _customRateController = TextEditingController();
  final _cookieDurationController = TextEditingController();
  final _expiresAtController = TextEditingController();
  bool _loading = false;
  String _attributionModel = 'first_click';

  static const List<String> _attributionOptions = ['first_click', 'last_click'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _destinationController.dispose();
    _customRateController.dispose();
    _cookieDurationController.dispose();
    _expiresAtController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final token = await ref.read(authTokenProvider.future);

      double? customRate;
      final customRateStr = _customRateController.text.trim();
      if (customRateStr.isNotEmpty) {
        customRate = double.tryParse(customRateStr);
      }

      int? cookieDurationDays;
      final cookieStr = _cookieDurationController.text.trim();
      if (cookieStr.isNotEmpty) {
        cookieDurationDays = int.tryParse(cookieStr);
      }

      final expiresAtStr = _expiresAtController.text.trim();
      final expiresAt = expiresAtStr.isEmpty ? null : expiresAtStr;

      final result = await affiliateGenerate(
        token,
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        destinationUrl: _destinationController.text.trim().isEmpty ? null : _destinationController.text.trim(),
        customRate: customRate,
        cookieDurationDays: cookieDurationDays,
        attributionModel: _attributionModel,
        expiresAt: expiresAt,
      );
      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        _showCreatedLinkDialog(context, result.fullUrl, result.link.linkCode);
      }
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

  void _showCreatedLinkDialog(BuildContext context, String fullUrl, String linkCode) {
    final displayUrl = fullUrl.isNotEmpty ? fullUrl : '${Uri.parse(CommonAPIController.affiliateLinks).origin}/affiliate/$linkCode';
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CreatedLinkDialog(
        fullUrl: displayUrl,
        linkCode: linkCode,
        onCopy: () {
          Clipboard.setData(ClipboardData(text: displayUrl));
          if (context.mounted) {
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
              SizedBox(height: 24.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AllColor.loginButtomColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.add_link_rounded,
                    size: 28.r,
                    color: AllColor.loginButtomColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New affiliate link',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColor.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Share this link to track clicks & conversions',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AllColor.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            Text(
              'Link details',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.grey500,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: 'e.g. Summer campaign',
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                prefixIcon: Icon(Icons.label_outline_rounded, size: 22.r, color: AllColor.grey500),
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
              controller: _descriptionController,
              maxLines: 2,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: 'Where or how you’ll use this link',
                labelText: 'Description',
                labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined, size: 22.r, color: AllColor.grey500),
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
                hintText: 'https://example.com/page',
                labelText: 'Destination URL',
                labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                prefixIcon: Icon(Icons.link_rounded, size: 22.r, color: AllColor.grey500),
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
            SizedBox(height: 28.h),
            Text(
              'Tracking & settings',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.grey500,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _customRateController,
              style: TextStyle(fontSize: 15.sp),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g. 10',
                labelText: 'Custom rate %',
                labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                prefixIcon: Icon(Icons.percent_rounded, size: 22.r, color: AllColor.grey500),
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
              controller: _cookieDurationController,
              style: TextStyle(fontSize: 15.sp),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 30',
                labelText: 'Cookie duration (days)',
                labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                prefixIcon: Icon(Icons.cookie_rounded, size: 22.r, color: AllColor.grey500),
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
            DropdownButtonFormField<String>(
              value: _attributionModel,
              decoration: InputDecoration(
                labelText: 'Attribution model',
                labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                prefixIcon: Icon(Icons.touch_app_rounded, size: 22.r, color: AllColor.grey500),
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
              items: _attributionOptions
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'first_click' ? 'First click' : 'Last click',
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ))
                  .toList(),
              onChanged: (String? value) {
                if (value != null) setState(() => _attributionModel = value);
              },
            ),
            SizedBox(height: 14.h),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null && mounted) {
                  final y = picked.year;
                  final m = picked.month.toString().padLeft(2, '0');
                  final d = picked.day.toString().padLeft(2, '0');
                  _expiresAtController.text = '$y-$m-$d';
                }
              },
              borderRadius: BorderRadius.circular(14.r),
              child: IgnorePointer(
                child: TextField(
                  controller: _expiresAtController,
                  readOnly: true,
                  style: TextStyle(fontSize: 15.sp),
                  decoration: InputDecoration(
                    hintText: 'Tap to pick date',
                    labelText: 'Expires at',
                    labelStyle: TextStyle(fontSize: 11.sp, color: AllColor.grey500),
                    prefixIcon: Icon(Icons.calendar_today_rounded, size: 22.r, color: AllColor.grey500),
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
              ),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
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
                          Icon(Icons.add_rounded, size: 22.r),
                          SizedBox(width: 8.w),
                          Text('Create link', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit link bottom sheet
// ---------------------------------------------------------------------------

class _EditLinkSheet extends ConsumerStatefulWidget {
  final AffiliateLinkModel link;
  final VoidCallback onSaved;

  const _EditLinkSheet({required this.link, required this.onSaved});

  @override
  ConsumerState<_EditLinkSheet> createState() => _EditLinkSheetState();
}

class _EditLinkSheetState extends ConsumerState<_EditLinkSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _destinationController;
  bool _active = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.link.name ?? '');
    _destinationController = TextEditingController(text: widget.link.destinationUrl ?? '');
    _active = widget.link.status == 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final token = await ref.read(authTokenProvider.future);
      await affiliateUpdate(
        token,
        id: widget.link.id,
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        status: _active ? 'active' : 'inactive',
        destinationUrl: _destinationController.text.trim().isEmpty ? null : _destinationController.text.trim(),
      );
      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        GlobalSnackbar.show(
          context,
          title: 'Updated',
          message: 'Link updated',
          type: CustomSnackType.success,
        );
      }
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
            SizedBox(height: 24.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AllColor.loginButtomColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 28.r,
                    color: AllColor.loginButtomColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit link',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColor.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.link.linkCode,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AllColor.grey500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            Text(
              'Link details',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.grey500,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.label_outline_rounded, size: 22.r, color: AllColor.grey500),
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
                hintText: 'https://example.com',
                labelText: 'Destination URL',
                prefixIcon: Icon(Icons.link_rounded, size: 22.r, color: AllColor.grey500),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AllColor.grey100.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AllColor.grey200),
              ),
              child: SwitchListTile(
                title: Text(
                  'Link active',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _active ? 'Clicks are being tracked' : 'Link is paused',
                  style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
                ),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                activeColor: AllColor.loginButtomColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
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
                          Icon(Icons.check_rounded, size: 22.r),
                          SizedBox(width: 8.w),
                          Text('Save changes', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
