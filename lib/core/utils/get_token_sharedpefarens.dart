import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

/// Provider to get authentication token from AuthLocalStorage
/// Returns login token if available, otherwise returns registration token
final authTokenProvider = FutureProvider<String?>((ref) async {
  final authStorage = ref.watch(authLocalStorageProvider);
  return await authStorage.getToken();
});
