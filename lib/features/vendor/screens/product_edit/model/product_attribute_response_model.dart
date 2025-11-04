class ProductAttributeResponse {
  final String status;
  final String message;
  final List<ProductAttribute> data;

  ProductAttributeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductAttributeResponse.fromJson(Map<String, dynamic> json) {
    return ProductAttributeResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((item) => ProductAttribute.fromJson(item))
          .toList(),
    );
  }
}

class ProductAttribute {
  final int id;
  final String name;
  final int vendorId;
  final List<AttributeValue> attributeValues;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.attributeValues,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vendorId: json['vendor_id'] ?? 0,
      attributeValues: (json['attribute_values'] as List)
          .map((v) => AttributeValue.fromJson(v))
          .toList(),
    );
  }
}

class AttributeValue {
  final int id;
  final String name;
  final int productAttributeId;

  AttributeValue({
    required this.id,
    required this.name,
    required this.productAttributeId,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      productAttributeId: json['product_attribute_id'] ?? 0,
    );
  }
}