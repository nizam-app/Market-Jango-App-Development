import 'package:market_jango/core/utils/auth_local_storage.dart';

/// Headers aligned with vendor API middleware (`token`, `id`, `user_type`, `email`).
Future<Map<String, String>> vendorOrderApiHeaders({String? tokenOverride}) async {
  final storage = AuthLocalStorage();
  final token = tokenOverride ?? await storage.getToken();
  final userId = await storage.getUserId();
  final userType = await storage.getUserType();
  final userJson = await storage.getUserJson();
  final email = userJson?['email']?.toString() ?? '';

  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'token': token,
    if (userId != null && userId.isNotEmpty) 'id': userId,
    if (userType != null && userType.isNotEmpty) 'user_type': userType,
    if (email.isNotEmpty) 'email': email,
  };
}
