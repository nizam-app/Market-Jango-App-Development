// core/screen/global_language/data/language_data.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

/// ------------------------------------------------------
///  Static language list  (UI te dekhabo)
/// ------------------------------------------------------
final languagesProvider = FutureProvider<List<String>>((ref) async {
  // jodi pore backend theke ante chao, ekhane change korba
  return const ['English', 'Français', 'Русский', 'Tiếng Việt'];
});

/// ------------------------------------------------------
///  Language update provider (api/user/update)
/// ------------------------------------------------------
final languageUpdateProvider =
    AutoDisposeAsyncNotifierProvider<
      LanguageUpdateNotifier,
      UserUpdateResponse?
    >(LanguageUpdateNotifier.new);

class LanguageUpdateNotifier
    extends AutoDisposeAsyncNotifier<UserUpdateResponse?> {
  @override
  Future<UserUpdateResponse?> build() async => null;

  Future<UserUpdateResponse?> updateLanguage(String code) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final res = await http.post(
      Uri.parse(BuyerAPIController.user_update),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'token': token,
      },
      body: jsonEncode({'language': code}), // {"language":"en"}
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to update language: ${res.statusCode} ${res.body}',
      );
    }

    final parsed = userUpdateResponseFromJson(res.body);
    state = AsyncData(parsed);
    return parsed;
  }
}

/// ------------------------------------------------------
///  MODEL : api/user/update response
///  (tumr screenshot er JSON onujayi)
/// ------------------------------------------------------

UserUpdateResponse userUpdateResponseFromJson(String s) =>
    UserUpdateResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class UserUpdateResponse {
  final String status;
  final String message;
  final UpdatedUser data;

  UserUpdateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserUpdateResponse.fromJson(Map<String, dynamic> j) {
    final dataJson = j['data'] as Map<String, dynamic>? ?? {};
    return UserUpdateResponse(
      status: (j['status'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
      data: UpdatedUser.fromJson(dataJson),
    );
  }
}

class UpdatedUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String language;
  final String image;

  UpdatedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.language,
    required this.image,
  });

  factory UpdatedUser.fromJson(Map<String, dynamic> j) => UpdatedUser(
    id: _toInt(j['id']),
    name: (j['name'] ?? '').toString(),
    email: (j['email'] ?? '').toString(),
    phone: (j['phone'] ?? '').toString(),
    language: (j['language'] ?? '').toString(),
    image: (j['image'] ?? '').toString(),
  );
}

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
