// chat_list_models.dart
class ChatListResponse {
  final String status;
  final String message;
  final List<ChatThread> data;

  ChatListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    return ChatListResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => ChatThread.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatThread {
  final int chatId;
  final int partnerId;
  final String partnerName;
  final String partnerImage;
  final String lastMessage;
  final String lastMessageTime; // already humanized by backend
  final bool isRead;

  ChatThread({
    required this.chatId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isRead,
  });

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
    chatId: json['chat_id'] ?? 0,
    partnerId: json['partner_id'] ?? 0,
    partnerName: json['partner_name'] ?? '',
    partnerImage: json['partner_image'] ?? '',
    lastMessage: json['last_message'] ?? '',
    lastMessageTime: json['last_message_time'] ?? '',
    isRead: json['is_read'] == 1,
  );
}