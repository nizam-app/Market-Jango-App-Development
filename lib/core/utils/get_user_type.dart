import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

// 1. Provider to expose the AuthLocalStorage instance
final authLocalStorageProvider = Provider<AuthLocalStorage>((ref) {
  return AuthLocalStorage();
});

/// Provider to get user type from AuthLocalStorage
/// Returns user_type from stored user JSON, or fallback to legacy key
final getUserTypeProvider = FutureProvider<String?>((ref) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  return await authStorage.getUserType();
});

/// Provider to get user ID from AuthLocalStorage
/// Returns user_id from stored user JSON, or fallback to legacy key
final getUserIdProvider = FutureProvider<String?>((ref) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  return await authStorage.getUserId();
});

/// Provider to get user email from AuthLocalStorage (from stored user JSON)
final getUserEmailProvider = FutureProvider<String?>((ref) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  final userJson = await authStorage.getUserJson();
  return userJson?['email']?.toString();
});

final vendorRoleProvider = FutureProvider<String?>((ref) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  final role = await authStorage.getVendorRole();
  final normalized = role?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
});

final vendorPermissionsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  return authStorage.getVendorPermissions();
});

bool _permissionValue(Map<String, dynamic> permissions, String key) {
  final value = permissions[key];
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

final canViewStaffManagementProvider = FutureProvider<bool>((ref) async {
  final isOwner = await ref.watch(isVendorOwnerProvider.future);
  if (isOwner) return true;
  final permissions = await ref.watch(vendorPermissionsProvider.future);
  return _permissionValue(permissions, 'can_manage_staff');
});

final canCreateOrDeleteStaffProvider = FutureProvider<bool>((ref) async {
  return ref.watch(isVendorOwnerProvider.future);
});

final canUpdateStaffRoleProvider = FutureProvider<bool>((ref) async {
  final isOwner = await ref.watch(isVendorOwnerProvider.future);
  if (isOwner) return true;
  final permissions = await ref.watch(vendorPermissionsProvider.future);
  return _permissionValue(permissions, 'can_manage_staff');
});

// --- Vendor feature permissions (UI access-control) ---

final isVendorOwnerProvider = FutureProvider<bool>((ref) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  final isOwner = await authStorage.getVendorIsOwner();
  if (isOwner) return true;

  final role = (await ref.watch(vendorRoleProvider.future))?.toLowerCase();
  return role == 'owner';
});

final canManageProductsProvider = FutureProvider<bool>((ref) async {
  final isOwner = await ref.watch(isVendorOwnerProvider.future);
  if (isOwner) return true;
  final permissions = await ref.watch(vendorPermissionsProvider.future);
  return _permissionValue(permissions, 'can_manage_products');
});

final canManageOrdersProvider = FutureProvider<bool>((ref) async {
  final isOwner = await ref.watch(isVendorOwnerProvider.future);
  if (isOwner) return true;
  final permissions = await ref.watch(vendorPermissionsProvider.future);
  return _permissionValue(permissions, 'can_manage_orders');
});

final canHandleReviewsReportsProvider = FutureProvider<bool>((ref) async {
  final isOwner = await ref.watch(isVendorOwnerProvider.future);
  if (isOwner) return true;
  final permissions = await ref.watch(vendorPermissionsProvider.future);
  return _permissionValue(permissions, 'can_manage_reports');
});
