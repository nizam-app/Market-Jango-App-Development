/// Product item from GET api/product/search
class FilterSearchProduct {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? regularPrice;
  final String? sellPrice;
  final int? vendorId;
  final int? categoryId;

  const FilterSearchProduct({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.regularPrice,
    this.sellPrice,
    this.vendorId,
    this.categoryId,
  });

  String get displayPrice =>
      (sellPrice != null && sellPrice!.isNotEmpty)
          ? sellPrice!
          : (regularPrice ?? '');

  factory FilterSearchProduct.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString() ??
        json['thumbnail']?.toString() ??
        json['image_url']?.toString();
    return FilterSearchProduct(
      id: _int(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: image?.trim().isNotEmpty == true ? image : null,
      regularPrice: json['regular_price']?.toString(),
      sellPrice: json['sell_price']?.toString(),
      vendorId: _intN(json['vendor_id']),
      categoryId: _intN(json['category_id']),
    );
  }
}

int _int(dynamic v, {int def = 0}) {
  if (v == null) return def;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? def;
}

int? _intN(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}
