class ProductAttribute {
  final int id;
  final String name;
  final List<AttributeValue> values;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.values,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'],
      name: json['name'],
      values: (json['attribute_values'] as List)
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
      id: json['id'],
      name: json['name'],
      productAttributeId: json['product_attribute_id'],
    );
  }
}
