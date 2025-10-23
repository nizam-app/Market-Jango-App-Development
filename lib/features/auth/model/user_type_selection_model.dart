import 'dart:convert';

class RegisterResponse {
  final String status, message;
  final RegisterData data;
  RegisterResponse({required this.status, required this.message, required this.data});

  factory RegisterResponse.fromRaw(String raw) =>
      RegisterResponse.fromJson(jsonDecode(raw));
  factory RegisterResponse.fromJson(Map<String, dynamic> j) => RegisterResponse(
    status: j['status'] ?? '',
    message: j['message'] ?? '',
    data: RegisterData.fromJson(j['data'] ?? {}),
  );
}

class RegisterData {
  final RegisteredUser user;
  final String token; // "Bearer ..."
  RegisterData({required this.user, required this.token});

  factory RegisterData.fromJson(Map<String, dynamic> j) => RegisterData(
    user: RegisteredUser.fromJson((j['uer'] ?? j['user']) ?? {}),
    token: j['token'] ?? '',
  );
}

class RegisteredUser {
  final int id;
  final String userType;
  final DateTime? createdAt, updatedAt;
  RegisteredUser({required this.id, required this.userType, this.createdAt, this.updatedAt});

  factory RegisteredUser.fromJson(Map<String, dynamic> j) => RegisteredUser(
    id: (j['id'] ?? 0) is num ? (j['id'] as num).toInt() : 0,
    userType: (j['user_type'] ?? '').toString().toLowerCase(),
    createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
    updatedAt: j['updated_at'] != null ? DateTime.tryParse(j['updated_at']) : null,
  );
}
