import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/chat_api.dart';
import 'package:market_jango/core/screen/buyer_massage/model/massage_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListController extends AsyncNotifier<List<ChatThread>> {
  http.Client _client = http.Client();

  @override
  Future<List<ChatThread>> build() async {
    return _fetch();
  }

  Future<List<ChatThread>> _fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse(
      ChatAPIController.massage_list,
    ); // e.g. /api/chat/user
    final res = await _client.get(
      uri,
      headers: {
        if (token != null) 'token': token,
        'Accept': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.statusCode} ${res.reasonPhrase}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List? ?? [])
        .map((e) => ChatThread.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  /// pull-to-refresh / ম্যানুয়াল রিফেচ
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// লোকালভাবে read flag টগল/আপডেট (API লাগলে এখানেই মারবেন)
  void markAsRead(int chatId) {
    final current = state.value;
    if (current == null) return;
    final updated = [
      for (final c in current)
        if (c.chatId == chatId)
          ChatThread(
            chatId: c.chatId,
            partnerId: c.partnerId,
            partnerName: c.partnerName,
            partnerImage: c.partnerImage,
            lastMessage: c.lastMessage,
            lastMessageTime: c.lastMessageTime,
            isRead: 1,
          )
        else
          c,
    ];
    state = AsyncData(updated);
  }
}

/// একটাই প্রোভাইডার ব্যবহার করবেন UI-তে
final chatListProvider =
    AsyncNotifierProvider<ChatListController, List<ChatThread>>(
      ChatListController.new,
    );
