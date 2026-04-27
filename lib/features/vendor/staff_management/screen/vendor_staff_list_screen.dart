import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/staff_management/data/vendor_moderator_api.dart';
import 'package:market_jango/features/vendor/staff_management/model/vendor_moderator_model.dart';
import 'package:market_jango/features/vendor/staff_management/screen/vendor_staff_upsert_screen.dart';

class VendorStaffListScreen extends ConsumerWidget {
  const VendorStaffListScreen({super.key});

  static const String routeName = '/vendor/staff';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMods = ref.watch(vendorModeratorsProvider);
    final canCreateDelete = ref.watch(canCreateOrDeleteStaffProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Staff Management'),
        actions: [
          canCreateDelete.when(
            data: (ok) => ok
                ? IconButton(
                    onPressed: () =>
                        context.push(VendorStaffUpsertScreen.routeName),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncMods.when(
        data: (mods) => _List(mods: mods),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.mods});
  final List<VendorModerator> mods;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCreateDelete = ref.watch(canCreateOrDeleteStaffProvider);

    Widget roleInfoCard() {
      return Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Moderator Roles',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            _RoleBullet(title: 'Owner', body: 'Full control'),
            _RoleBullet(
              title: 'Manager',
              body: 'Manage products, orders, staff',
            ),
            _RoleBullet(
              title: 'Moderator',
              body: 'Approve/reject product listings',
            ),
            _RoleBullet(
              title: 'Support',
              body: 'Handle reports/reviews; support staff',
            ),
          ],
        ),
      );
    }

    if (mods.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_alt_outlined, size: 44.r, color: Colors.grey),
              SizedBox(height: 10.h),
              Text(
                'No staff found',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                'Add staff sub-accounts to help manage your store.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              SizedBox(height: 16.h),
              canCreateDelete.when(
                data: (ok) => ok
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColor.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            context.push(VendorStaffUpsertScreen.routeName),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('Add Staff'),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vendorModeratorsProvider);
      },
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
        itemCount: mods.length + 1,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == 0) return roleInfoCard();
          final m = mods[index - 1];
          final name = m.user?.name ?? 'User #${m.userId}';
          final email = m.user?.email ?? '';

          return InkWell(
            onTap: () => context.push(
              VendorStaffUpsertScreen.routeName,
              extra: m.id,
            ),
            onLongPress: () {
              GlobalSnackbar.show(
                context,
                title: 'Tip',
                message: 'Tap to view/edit staff details.',
              );
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: m.isActive
                        ? AllColor.orange.withOpacity(0.12)
                        : Colors.grey.withOpacity(0.2),
                    child: Icon(
                      Icons.person_outline,
                      color: m.isActive ? AllColor.orange : Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                            _RoleChip(role: m.role),
                            SizedBox(width: 8.w),
                            _StatusChip(active: m.isActive),
                          ],
                        ),
                        if (email.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16.sp,
                              color: Colors.grey.shade700,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'View / Edit',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.green.withOpacity(0.12) : Colors.grey.shade200;
    final fg = active ? Colors.green.shade700 : Colors.grey.shade700;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final String role;
  @override
  Widget build(BuildContext context) {
    final r = role.trim().toLowerCase();
    final Color color = switch (r) {
      'manager' => Colors.blue,
      'moderator' => Colors.purple,
      'support' => Colors.teal,
      _ => Colors.orange,
    };
    final Color textColor = switch (r) {
      'manager' => Colors.blue.shade700,
      'moderator' => Colors.purple.shade700,
      'support' => Colors.teal.shade700,
      _ => Colors.orange.shade700,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

class _RoleBullet extends StatelessWidget {
  const _RoleBullet({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                color: AllColor.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '$title: $body',
              style: TextStyle(
                height: 1.35,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

