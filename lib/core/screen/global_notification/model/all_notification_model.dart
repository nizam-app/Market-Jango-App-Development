import 'package:intl/intl.dart';

class NotificationModel {
  final int id;
  final String name;
  final String message;
  final bool isRead;
  final int senderId;
  final int receiverId;
  final DateTime? createdAt;
  final Sender sender;

  NotificationModel({
    required this.id,
    required this.name,
    required this.message,
    required this.isRead,
    required this.senderId,
    required this.receiverId,
    this.createdAt,
    required this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'];
    return NotificationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'] == '1',
      senderId: json['sender_id'] is int
          ? json['sender_id'] as int
          : int.tryParse('${json['sender_id'] ?? 0}') ?? 0,
      receiverId: json['receiver_id'] is int
          ? json['receiver_id'] as int
          : int.tryParse('${json['receiver_id'] ?? 0}') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      sender: senderRaw is Map<String, dynamic>
          ? Sender.fromJson(senderRaw)
          : Sender(id: 0, name: '', email: ''),
    );
  }

  /// 🔹 সময় ফরম্যাট করার জন্য হেল্পার ফাংশন
  String get formattedTime {
    if (createdAt == null) return '';
    return DateFormat('hh:mm a').format(createdAt!); // উদাহরণ: 09:39 AM
  }

  /// 🔹 তারিখ ফরম্যাট করার জন্য হেল্পার ফাংশন
  String get formattedDate {
    if (createdAt == null) return '';
    return DateFormat('yyyy-MM-dd').format(createdAt!); // উদাহরণ: 2025-10-25
  }
}

class Sender {
  final int id;
  final String name;
  final String email;

  Sender({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}