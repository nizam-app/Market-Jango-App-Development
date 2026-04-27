class VendorModeratorUser {
  final int id;
  final String name;
  final String email;
  final String? status;
  final String? lastActiveAt;

  const VendorModeratorUser({
    required this.id,
    required this.name,
    required this.email,
    this.status,
    this.lastActiveAt,
  });

  factory VendorModeratorUser.fromJson(Map<String, dynamic> json) {
    return VendorModeratorUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: json['status']?.toString(),
      lastActiveAt: json['last_active_at']?.toString(),
    );
  }
}

class VendorModerator {
  final int id;
  final int vendorId;
  final int userId;
  final String role;
  final bool isActive;
  final int? createdByUserId;
  final VendorModeratorUser? user;

  const VendorModerator({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.role,
    required this.isActive,
    this.createdByUserId,
    this.user,
  });

  static bool _parseBool(dynamic v, {bool fallback = true}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == '1' || s == 'true' || s == 'yes') return true;
      if (s == '0' || s == 'false' || s == 'no') return false;
    }
    return fallback;
  }

  factory VendorModerator.fromJson(Map<String, dynamic> json) {
    return VendorModerator(
      id: (json['id'] as num?)?.toInt() ?? 0,
      vendorId: (json['vendor_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      role: (json['role'] ?? '').toString(),
      isActive: _parseBool(json['is_active'], fallback: true),
      createdByUserId: (json['created_by_user_id'] as num?)?.toInt(),
      user: json['user'] is Map<String, dynamic>
          ? VendorModeratorUser.fromJson(
              (json['user'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

