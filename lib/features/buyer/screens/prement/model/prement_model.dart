class ProductData {
  final List<String> shippingAddress;
  final List<String> contact;
  final List<Item> items;
  final List<ShippingOption> shippingOptions;
  final String selectedShippingId;
  final String selectedPaymentMethod;

  ProductData({
    required this.shippingAddress,
    required this.contact,
    required this.items,
    required this.shippingOptions,
    required this.selectedShippingId,
    required this.selectedPaymentMethod,
  });

  factory ProductData.fromJson(Map<String, dynamic> j) => ProductData(
    shippingAddress: List<String>.from(j['shippingAddress'] ?? []),
    contact: List<String>.from(j['contact'] ?? []),
    items: (j['items'] as List? ?? []).map((e) => Item.fromJson(e)).toList(),
    shippingOptions:
    (j['shippingOptions'] as List? ?? []).map((e) => ShippingOption.fromJson(e)).toList(),
    selectedShippingId: j['selectedShippingId'] ?? '',
    selectedPaymentMethod: j['selectedPaymentMethod'] ?? 'card',
  );
}

class Item {
  final String title;
  final double price;
  final String image;
  Item({required this.title, required this.price, required this.image});

  factory Item.fromJson(Map<String, dynamic> j) =>
      Item(title: j['title'] ?? '', price: (j['price'] ?? 0).toDouble(), image: j['image'] ?? '');
}

class ShippingOption {
  final String id;
  final String label;
  final double price;
  ShippingOption({required this.id, required this.label, required this.price});

  factory ShippingOption.fromJson(Map<String, dynamic> j) => ShippingOption(
    id: j['id'] ?? '',
    label: j['label'] ?? '',
    price: (j['price'] ?? 0).toDouble(),
  );
}