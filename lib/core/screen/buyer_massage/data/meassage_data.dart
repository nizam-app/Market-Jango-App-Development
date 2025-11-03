import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/massage_list_model.dart';

class ChatController extends StateNotifier<AsyncValue<List<ChatThread>>> {
  ChatController() : super(const AsyncValue.loading());

  final String _baseUrl = BuyerAPIController.massage_list;

  Future<void> getChatList() async {
    try {
      state = const AsyncValue.loading();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'token': token,
          
        },
      );
      Logger().i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final List list = body['data'];
          final chats = list.map((e) => ChatThread.fromJson(e)).toList();
          state = AsyncValue.data(chats);
        } else {
          throw Exception(body['message']);
        }
      } else {
        throw Exception('Failed to load chat list');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      Logger().e('Error fetching chat list: $e');
    }
  }
}