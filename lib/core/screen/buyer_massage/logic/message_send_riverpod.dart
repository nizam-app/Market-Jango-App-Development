// send_message_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/chat_api.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_model.dart'; // ChatMessage
import 'package:market_jango/core/utils/image_check_before_post.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

final chatSendProvider =
    StateNotifierProvider<ChatSendNotifier, AsyncValue<ChatMessage?>>(
      (ref) => ChatSendNotifier(ref),
    );

class ChatSendNotifier extends StateNotifier<AsyncValue<ChatMessage?>> {
  ChatSendNotifier(this.ref) : super(const AsyncData(null));
  final Ref ref;

  /// Returns the created/sent ChatMessage on success; null on failure.
  Future<ChatMessage?> send({
    required int partnerId,
    String? message,
    List<File>? images,
  }) async {
    if ((message == null || message.trim().isEmpty) &&
        (images == null || images.isEmpty)) {
      // need at least one of message or image
      return null;
    }

    try {
      state = const AsyncLoading();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse(ChatAPIController.send(partnerId));
      final req = http.MultipartRequest('POST', uri);

      if (token != null) req.headers['token'] = token;

      if (message != null && message.trim().isNotEmpty) {
        req.fields['message'] = message.trim();
      }

      List<File> galleryCompressed = [];
      final toCompress = images ?? const <File>[];

      if (toCompress.isNotEmpty) {
        galleryCompressed = await ImageManager.compressAll(toCompress);
        for (final f in galleryCompressed) {
          req.files.add(
            await http.MultipartFile.fromPath(
              'image[]',
              f.path,
              filename: p.basename(f.path),
            ),
          );
        }
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        final data = ChatMessage.fromJson(map['data'] as Map<String, dynamic>);
        state = AsyncData(data);
        return data;
      } else {
        state = AsyncError(
          'Failed: ${res.statusCode} ${res.reasonPhrase}\n${res.body}',
          StackTrace.current,
        );
        return null;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}
