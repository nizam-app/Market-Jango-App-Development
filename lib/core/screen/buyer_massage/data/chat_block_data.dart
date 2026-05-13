import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/chat_api.dart';
import 'package:market_jango/core/screen/buyer_massage/data/meassage_data.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class ChatBlockApi {
  ChatBlockApi._();

  static Future<Map<String, String>> _headers() async {
    final token = await AuthLocalStorage().getToken();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    };
  }

  static String _errorMessage(int status, String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>?;
      final msg = map?['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    return 'Request failed ($status)';
  }

  /// Parses `GET /api/chat/blocked` → set of blocked user ids.
  static Set<int> _parseBlockedIds(dynamic data) {
    final out = <int>{};
    if (data is! List) return out;
    for (final e in data) {
      if (e is int) {
        out.add(e);
      } else if (e is num) {
        out.add(e.toInt());
      } else if (e is Map<String, dynamic>) {
        final raw = e['user_id'] ?? e['id'] ?? e['partner_id'] ?? e['blocked_user_id'];
        final id = int.tryParse('$raw');
        if (id != null) out.add(id);
      }
    }
    return out;
  }

  static Future<Set<int>> fetchBlockedUserIds() async {
    final uri = Uri.parse(ChatAPIController.chatBlocked);
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.statusCode, res.body));
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return _parseBlockedIds(map['data']);
  }

  static Future<void> blockUser(int userId) async {
    final uri = Uri.parse(ChatAPIController.chatBlock(userId));
    final res = await http.post(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.statusCode, res.body));
    }
  }

  static Future<void> unblockUser(int userId) async {
    final uri = Uri.parse(ChatAPIController.chatUnblock(userId));
    final res = await http.delete(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception(_errorMessage(res.statusCode, res.body));
    }
  }
}

class BlockedChatUserIds extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() => ChatBlockApi.fetchBlockedUserIds();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(ChatBlockApi.fetchBlockedUserIds);
  }
}

final blockedChatUserIdsProvider =
    AsyncNotifierProvider<BlockedChatUserIds, Set<int>>(BlockedChatUserIds.new);

/// After block/unblock, refresh blocked ids and chat inbox.
Future<void> refreshChatBlockAndInbox(WidgetRef ref) async {
  await ref.read(blockedChatUserIdsProvider.notifier).reload();
  await ref.read(chatListProvider.notifier).refresh();
}
