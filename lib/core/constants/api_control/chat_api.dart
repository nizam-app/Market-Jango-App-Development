import 'global_api.dart';

class ChatAPIController {
  static final String _base_api = "$api/api";
  static String massage_list = "$_base_api/chat/user";
  static String chat_history(int id) => "$_base_api/chat/history/$id";
  static String send(int id) => "$_base_api/chat/send/$id";
  static String sendOffer(int receiverId) => "$_base_api/chat/offer/$receiverId";
  static String acceptOffer(int offerId) => "$_base_api/cart/offer/$offerId/add";
}
 