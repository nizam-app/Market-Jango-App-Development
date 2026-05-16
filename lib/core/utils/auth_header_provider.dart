import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

/// Builds the required auth headers used by this backend:
/// - token
/// - id
/// - email
final authHeadersProvider = FutureProvider<Map<String, String>>((ref) async {
  final token = await ref.watch(authTokenProvider.future);
  final id = await ref.watch(getUserIdProvider.future);
  final email = await ref.watch(getUserEmailProvider.future);

  if (token == null || token.isEmpty) throw Exception('Token not found');
  if (id == null || id.isEmpty) throw Exception('User id not found');
  if (email == null || email.isEmpty) throw Exception('User email not found');

  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'token': token,
    'id': id,
    'email': email,
  };
});

