import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Provider to expose the SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

final getUserTypeProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);

  // Get the 'userType' string. It returns null if not found.
  return prefs.getString('user_type');
});
