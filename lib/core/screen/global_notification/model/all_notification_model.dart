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
    return NotificationModel(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true, // Handle 0/1 and true/false
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      sender: Sender.fromJson(json['sender']),
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