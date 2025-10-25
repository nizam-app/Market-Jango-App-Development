import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'get_user_type.dart';

final authTokenProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);

  // Get the 'userType' string. It returns null if not found.
  return prefs.getString('auth_token');
});
