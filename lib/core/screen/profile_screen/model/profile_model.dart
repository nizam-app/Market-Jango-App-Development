class UserModel {
  final int id;
  final String name;
  final String image;
  final String email;
  final String phone;
  final String userType;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.email,
    required this.phone,
    required this.userType,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: (json['image'] != null && json['image'].isNotEmpty) ? json['image'] : 'https://empy.com/images/no-image.png',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
      status: json['status'] ?? '',
    );
  }
}