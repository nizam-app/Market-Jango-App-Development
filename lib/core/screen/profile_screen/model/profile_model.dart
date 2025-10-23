class UserModel {
  final int id;
  final String name;
  final String email;
  final String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? '',
    );
  }
}
