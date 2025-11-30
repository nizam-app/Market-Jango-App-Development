// // lib/core/data/models/massage_model.dart
//
// import 'dart:convert'; // Required for jsonEncode and jsonDecode
//
// class ChatModel {
//   final String avatar;
//   final String name;
//   final String message;
//   final String time;
//   final bool unread;
//
//   const ChatModel({
//     required this.avatar,
//     required this.name,
//     required this.message,
//     required this.time,
//     required this.unread,
//   });
//
//   // Factory constructor to create a ChatModel from a JSON map
//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     return ChatModel(
//       avatar: json['avatar'] as String,
//       name: json['name'] as String,
//       message: json['message'] as String,
//       time: json['time'] as String,
//       unread: json['unread'] as bool,
//     );
//   }
//
//   // Method to convert a ChatModel instance to a JSON map
//   Map<String, dynamic> toJson() {
//     return {
//       'avatar': avatar,
//       'name': name,
//       'message': message,
//       'time': time,
//       'unread': unread,
//     };
//   }
//
//   // Optional: Convenience method to convert a ChatModel instance to a JSON string
//   String toJsonString() => jsonEncode(toJson());
//
//   // Optional: Convenience factory to create a ChatModel from a JSON string
//   factory ChatModel.fromJsonString(String source) =>
//       ChatModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
// }