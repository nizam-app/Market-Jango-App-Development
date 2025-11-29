import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/chat_api.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fetcher
Future<List<ChatMessage>> _fetchChatHistory(int partnerId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final uri = Uri.parse(ChatAPIController.chat_history(partnerId));
  final res = await http.get(uri, headers: {if (token != null) 'token': token});

  if (res.statusCode == 200) {
    final parsed = ChatHistoryResponse.fromBody(res.body);
    return parsed.data;
  }

  throw Exception('Failed to fetch chat history: ${res.statusCode}');
}

final chatHistoryStreamProvider = StreamProvider.autoDispose
    .family<List<ChatMessage>, int>((ref, partnerId) async* {
      // প্রথমবার তৎক্ষণাৎ লোড
      yield await _fetchChatHistory(partnerId);

      // এরপর প্রতি 3 সেকেন্ডে রিফ্রেশ
      yield* Stream.periodic(
        const Duration(seconds: 3),
      ).asyncMap((_) => _fetchChatHistory(partnerId));
    });
