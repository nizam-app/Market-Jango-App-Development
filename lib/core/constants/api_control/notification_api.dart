import 'global_api.dart';

class NotificationAPIController {
  static final String _base_api = "$api/api";

  /// `GET /api/notification/`
  static String notificationList = "$_base_api/notification/";

  /// `PUT /api/notification/read/{id}`
  static String notificationRead(int id) => "$_base_api/notification/read/$id";

  /// `POST /api/save-fcm`
  static String saveFcm = "$_base_api/save-fcm";
}