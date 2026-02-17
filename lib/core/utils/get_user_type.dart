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
