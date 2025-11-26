import 'global_api.dart';

class ChatAPIController {
  static String _base_api = "$api/api";
  static String massage_list = "$_base_api/chat/user";
  static String chat_history(int id) => "$_base_api/chat/history/$id";
  static String send(int id) => "$_base_api/chat/send/$id";
}
