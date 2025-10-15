import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/features/auth/data/user_type_selection_token_save.dart';
import 'package:market_jango/features/auth/model/user_type_selection_model.dart';


final registerUrl = AuthAPIController.registerTypeSelection; // <-- change
// UI selected type
final userTypeP = StateProvider<String>((_) => 'Buyer');

// in-memory token (nullable)
final tokenP = StateProvider<String?>((_) => null);

// storage
final tokenStoreP = Provider<TokenStorage>((_) => TokenStorage());

// register flow
final registerP = StateNotifierProvider<RegisterC, AsyncValue<RegisterResponse?>>(
      (ref) => RegisterC(ref),
);

class RegisterC extends StateNotifier<AsyncValue<RegisterResponse?>> {
  RegisterC(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> loadSavedToken() async {
    final t = await ref.read(tokenStoreP).read();
    ref.read(tokenP.notifier).state = t;
  }

  Future<void> logout() async {
    await ref.read(tokenStoreP).clear();
    ref.read(tokenP.notifier).state = null;
  }

  Future<void> submit() async {
    state = const AsyncLoading();
    try {
      final type = ref.read(userTypeP).toLowerCase();
      final res = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_type': type}),
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw 'HTTP ${res.statusCode}';
      }

      final parsed = RegisterResponse.fromRaw(res.body);
      if (parsed.status.toLowerCase() != 'success') {
        throw parsed.message.isNotEmpty ? parsed.message : 'Registration failed';
      }
      if (parsed.data.token.isEmpty) throw 'Missing token';

      await ref.read(tokenStoreP).save(parsed.data.token);
      ref.read(tokenP.notifier).state = parsed.data.token;

      state = AsyncData(parsed);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
