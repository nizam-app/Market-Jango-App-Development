import 'dart:convert';

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
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      message: json['message']?.toString() ?? '',
      image: json['image']?.toString(),
      publicId: json['public_id']?.toString(),
      isRead: json['is_read'] ?? 0,
      replyTo: (json['reply_to'] is int) ? json['reply_to'] : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Helper you can use in UI:
  bool isMine(int myUserId) => senderId == myUserId;
}
