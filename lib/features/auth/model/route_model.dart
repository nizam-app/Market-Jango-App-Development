class RouteModel {
  final int id;
  final String name;

  RouteModel({required this.id, required this.name});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
