import 'dart:convert';
import 'package:market_jango/core/screen/buyer_massage/model/chat_offer_model.dart';

class ChatHistoryResponse {
  final String status;
  final String message;
  final List<ChatMessage> data;
  ChatHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static ChatHistoryResponse fromBody(String body) =>
      ChatHistoryResponse.fromJson(jsonDecode(body));
}

class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String? image;
  final String? publicId;
  final int isRead; // 0/1 from API
  final int? replyTo; // sometimes null or 0
  final String? createdAt;
  final String? updatedAt;
  final ChatOffer? offer; // Offer data if this is an offer message

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.image,
    this.publicId,
    required this.isRead,
    this.replyTo,
    this.createdAt,
    this.updatedAt,
    this.offer,
  });

  /// Helper to safely convert various types to int
  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      // Try parsing as bool string
      if (value.toLowerCase() == 'true') return 1;
      if (value.toLowerCase() == 'false') return 0;
    }
    return defaultValue;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _toInt(json['id']),
      senderId: _toInt(json['sender_id']),
      receiverId: _toInt(json['receiver_id']),
      message: json['message']?.toString() ?? '',
      image: json['image']?.toString(),
      publicId: json['public_id']?.toString(),
      isRead: _toInt(json['is_read']),
      replyTo: json['reply_to'] != null ? _toInt(json['reply_to']) : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      offer: json['offer'] != null
          ? ChatOffer.fromJson(json['offer'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Helper you can use in UI:
  bool isMine(int myUserId) => senderId == myUserId;
  
  /// Check if this message is an offer message
  bool get isOfferMessage => offer != null;
}
