class UserModel {
  final int id;
  final String name;
  final String image;
  final String email;
  final String phone;
  final String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
    required this.phone,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
    );
  }
}
