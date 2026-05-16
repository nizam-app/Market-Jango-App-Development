import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/utils/auth_header_provider.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/staff_management/data/vendor_moderator_api.dart';

class VendorStaffUpsertScreen extends ConsumerStatefulWidget {
  const VendorStaffUpsertScreen({super.key, this.moderatorId});

  /// If provided, screen becomes "edit" for that moderator.
  final int? moderatorId;

  static const String routeName = '/vendor/staff/edit';

  @override
  ConsumerState<VendorStaffUpsertScreen> createState() =>
      _VendorStaffUpsertScreenState();
}

class _VendorStaffUpsertScreenState
    extends ConsumerState<VendorStaffUpsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _role = 'Manager';
  bool _isActive = true;
  bool _saving = false;

  bool get _isEdit => widget.moderatorId != null && widget.moderatorId! > 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.moderatorId;
    final asyncDetail = _isEdit
        ? ref.watch(vendorModeratorProvider(id!))
        : const AsyncValue.data(null);
    final canCreateDelete = ref.watch(canCreateOrDeleteStaffProvider);
    final canUpdateRole = ref.watch(canUpdateStaffRoleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEdit ? 'Edit Staff' : 'Add Staff'),
      ),
      body: asyncDetail.when(
        data: (detail) {
          if (_isEdit && detail != null && _nameCtrl.text.isEmpty) {
            _nameCtrl.text = detail.user?.name ?? '';
            _emailCtrl.text = detail.user?.email ?? '';
            _role = detail.role;
            _isActive = detail.isActive;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: _isEdit ? 'Update Staff' : 'Create Staff',
                    subtitle: _isEdit
                        ? 'Update role and active status for this staff account.'
                        : 'Create a staff sub-account for your store.',
                  ),
                  SizedBox(height: 14.h),
                  Container(
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
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          enabled: !_isEdit,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (_isEdit) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Name required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _emailCtrl,
                          enabled: !_isEdit,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (_isEdit) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Email required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        if (!_isEdit)
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().length < 8) {
                                return 'Min 8 characters';
                              }
                              return null;
                            },
                          ),
                        if (!_isEdit) SizedBox(height: 12.h),
                        DropdownButtonFormField<String>(
                          initialValue: _role,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          disabledHint: Text(_role),
                          items: const [
                            DropdownMenuItem(
                              value: 'Manager',
                              child: Text('Manager'),
                            ),
                            DropdownMenuItem(
                              value: 'Moderator',
                              child: Text('Moderator'),
                            ),
                            DropdownMenuItem(
                              value: 'Support',
                              child: Text('Support'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            final ok = canUpdateRole.valueOrNull ?? true;
                            if (!ok) return;
                            setState(() => _role = v);
                          },
                        ),
                        if (_isEdit) ...[
                          SizedBox(height: 6.h),
                          SwitchListTile.adaptive(
                            value: _isActive,
                            onChanged: (canUpdateRole.valueOrNull ?? true)
                                ? (v) => setState(() => _isActive = v)
                                : null,
                            title: const Text('Active'),
                            subtitle: Text(
                              _isActive
                                  ? 'This account can login and access vendor features.'
                                  : 'This account is disabled and cannot login.',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _ActionBar(
                    isEdit: _isEdit,
                    saving: _saving,
                    onSave: _onSave,
                    onDelete: _onDelete,
                    canDelete: canCreateDelete.valueOrNull ?? false,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_isEdit && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final headers = await ref.read(authHeadersProvider.future);

      if (_isEdit) {
        final id = widget.moderatorId!;
        await VendorModeratorApi.update(
          headers: headers,
          moderatorId: id,
          role: _role,
          isActive: _isActive,
        );
        ref.invalidate(vendorModeratorProvider(id));
      } else {
        await VendorModeratorApi.create(
          headers: headers,
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _role,
        );
      }

      ref.invalidate(vendorModeratorsProvider);
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Success',
          message: _isEdit ? 'Staff updated' : 'Staff created',
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: CustomSnackType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove staff'),
        content: const Text('Are you sure you want to remove this staff?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _saving = true);
    try {
      final headers = await ref.read(authHeadersProvider.future);
      await VendorModeratorApi.delete(
        headers: headers,
        moderatorId: widget.moderatorId!,
      );
      ref.invalidate(vendorModeratorsProvider);
      if (mounted) {
        GlobalSnackbar.show(
          context,
          title: 'Success',
          message: 'Staff removed',
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      GlobalSnackbar.show(
        context,
        title: 'Error',
        message: e.toString(),
        type: CustomSnackType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade700, height: 1.35),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isEdit,
    required this.saving,
    required this.onSave,
    required this.onDelete,
    required this.canDelete,
  });

  final bool isEdit;
  final bool saving;
  final Future<void> Function() onSave;
  final Future<void> Function() onDelete;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            onPressed: saving ? null : () => onSave(),
            child: Text(
              saving ? 'Saving...' : 'Save',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (isEdit) ...[
          SizedBox(width: 10.w),
          if (canDelete)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: IconButton(
                onPressed: saving ? null : () => onDelete(),
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                tooltip: 'Remove staff',
              ),
            ),
        ],
      ],
    );
  }
}

