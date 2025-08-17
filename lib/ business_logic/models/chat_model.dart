class ChatMessage {
  final String? text;
  final bool isSender;
  final String time;
  final bool isOrderSummary;
  final String? orderNumber;
  final String? deliveryType;
  final int? itemCount;
  final List<String>? imageUrls;


  ChatMessage({
    this.text,
    required this.isSender,
    required this.time,
    this.isOrderSummary = false,
    this.orderNumber,
    this.deliveryType,
    this.itemCount,
    this.imageUrls,
  }) : assert(isOrderSummary ? (orderNumber != null && deliveryType != null &&
      itemCount != null && imageUrls != null) : text != null);

  // Convert a ChatMessage instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isSender': isSender,
      'time': time,
      'isOrderSummary': isOrderSummary,
      'orderNumber': orderNumber,
      'deliveryType': deliveryType,
      'itemCount': itemCount,
      'imageUrls': imageUrls,
    };
  }

  // Create a ChatMessage instance from a JSON map.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isSender: json['isSender'],
      time: json['time'],
      isOrderSummary: json['isOrderSummary'] ?? false,
      orderNumber: json['orderNumber'],
      deliveryType: json['deliveryType'],
      itemCount: json['itemCount'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
    );
  }
}