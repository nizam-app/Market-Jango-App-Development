class DriverRegisterModel {
  final String status;
  final String message;
  final DriverData data;

  DriverRegisterModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverRegisterModel.fromJson(Map<String, dynamic> json) {
    return DriverRegisterModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: DriverData.fromJson(json['data'] ?? {}),
    );
  }
}

class DriverData {
  final String carName;
  final String carModel;
  final String location;
  final String price;
  final String routeId;
  final int id;

  DriverData({
    required this.carName,
    required this.carModel,
    required this.location,
    required this.price,
    required this.routeId,
    required this.id,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      carName: json['car_name'] ?? '',
      carModel: json['car_model'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? '',
      routeId: json['route_id']?.toString() ?? '',
      id: json['id'] ?? 0,
    );
  }
}
