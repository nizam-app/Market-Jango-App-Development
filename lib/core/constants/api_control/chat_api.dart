import 'global_api.dart';

class ChatAPIController {
  static final String _base_api = "$api/api";
  static String massage_list = "$_base_api/chat/user";
  static String chat_history(int id) => "$_base_api/chat/history/$id";
  static String send(int id) => "$_base_api/chat/send/$id";
  static String sendOffer(int receiverId) => "$_base_api/chat/offer/$receiverId";
  static String acceptOffer(int offerId) => "$_base_api/cart/offer/$offerId/add";

  /// POST — block `userId` for the authenticated user (all roles use same API).
  static String chatBlock(int userId) => "$_base_api/chat/block/$userId";

  /// DELETE — unblock `userId`.
  static String chatUnblock(int userId) => "$_base_api/chat/unblock/$userId";

  /// GET — list blocked user ids for the current user.
  static String get chatBlocked => "$_base_api/chat/blocked";
}
 