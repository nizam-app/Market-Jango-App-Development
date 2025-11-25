// class ProductAttributeResponse {
//   final String status;
//   final String message;
//   final List<MyProductAttribute> data;
//
//   ProductAttributeResponse({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProductAttributeResponse.fromJson(Map<String, dynamic> json) {
//     return ProductAttributeResponse(
//       status: (json['status'] ?? '').toString(),
//       message: (json['message'] ?? '').toString(),
//       data: (json['data'] as List<dynamic>? ?? [])
//           .map((e) => MyProductAttribute.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// class MyProductAttribute {
//   final int id;
//   final String name;
//   final int vendorId;
//   final List<ProductAttributeValue> values;
//
//   MyProductAttribute({
//     required this.id,
//     required this.name,
//     required this.vendorId,
//     required this.values,
//   });
//
//   factory MyProductAttribute.fromJson(Map<String, dynamic> json) {
//     return MyProductAttribute(
//       id: _toInt(json['id']),
//       name: (json['name'] ?? '').toString(),
//       vendorId: _toInt(json['vendor_id']),
//       values: (json['attribute_values'] as List<dynamic>? ?? [])
//           .map((e) => ProductAttributeValue.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// class ProductAttributeValue {
//   final int id;
//   final String name;
//   final int productAttributeId;
//
//   ProductAttributeValue({
//     required this.id,
//     required this.name,
//     required this.productAttributeId,
//   });
//
//   factory ProductAttributeValue.fromJson(Map<String, dynamic> json) {
//     return ProductAttributeValue(
//       id: _toInt(json['id']),
//       name: (json['name'] ?? '').toString(),
//       productAttributeId: _toInt(json['product_attribute_id']),
//     );
//   }
// }
//
// int _toInt(dynamic v) =>
//     v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);