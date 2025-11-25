import '../model/cart_model.dart'; // CartItem

class CartUpdateResponse {
  final String status;
  final String message;
  final CartItem data;

  CartUpdateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CartUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CartUpdateResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: CartItem.fromJson(json['data'] ?? {}),
    );
  }
}
