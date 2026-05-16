// Product payload from vendor barcode APIs (doc/VENDOR_BARCODE_AND_SCANNER_API.md).

import 'dart:convert';

int _toInt(dynamic v, {int d = 0}) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? d;
}

double _toDouble(dynamic v, {double d = 0}) {
  if (v == null) return d;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? d;
}

String _s(dynamic v) => v?.toString() ?? '';

String? _nullableString(dynamic v) {
  if (v == null) return null;
  final t = v.toString();
  return t.isEmpty ? null : t;
}

class VendorBarcodeVariant {
  final String? size;
  final String? color;
  final dynamic attributes;

  const VendorBarcodeVariant({this.size, this.color, this.attributes});

  factory VendorBarcodeVariant.fromJson(dynamic j) {
    if (j is! Map<String, dynamic>) return const VendorBarcodeVariant();
    return VendorBarcodeVariant(
      size: _nullableString(j['size']),
      color: _nullableString(j['color']),
      attributes: j['attributes'],
    );
  }

  bool get isEmpty =>
      (size == null || size!.isEmpty) &&
      (color == null || color!.isEmpty) &&
      attributes == null;

  String get displayLine {
    if (isEmpty) return '';
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add('Size: $size');
    if (color != null && color!.isNotEmpty) parts.add('Color: $color');
    if (attributes != null) {
      if (attributes is Map || attributes is List) {
        try {
          parts.add(jsonEncode(attributes));
        } catch (_) {
          parts.add(attributes.toString());
        }
      } else {
        parts.add(attributes.toString());
      }
    }
    return parts.join(' · ');
  }
}

class VendorBarcodeCategoryBrief {
  final int id;
  final String name;

  const VendorBarcodeCategoryBrief({required this.id, required this.name});

  factory VendorBarcodeCategoryBrief.fromJson(dynamic j) {
    if (j is! Map<String, dynamic>) {
      return const VendorBarcodeCategoryBrief(id: 0, name: '');
    }
    return VendorBarcodeCategoryBrief(
      id: _toInt(j['id']),
      name: _s(j['name']),
    );
  }
}

class VendorBarcodeVendorBrief {
  final int id;
  final String businessName;
  final String? coverImage;

  const VendorBarcodeVendorBrief({
    required this.id,
    required this.businessName,
    this.coverImage,
  });

  factory VendorBarcodeVendorBrief.fromJson(dynamic j) {
    if (j is! Map<String, dynamic>) {
      return const VendorBarcodeVendorBrief(id: 0, businessName: '');
    }
    return VendorBarcodeVendorBrief(
      id: _toInt(j['id']),
      businessName: _s(j['business_name']),
      coverImage: _nullableString(j['cover_image']),
    );
  }
}

class VendorBarcodeProduct {
  final int id;
  final String name;
  final String barcode;
  final double sellPrice;
  final double regularPrice;
  final int stock;
  final String image;
  final String description;
  final String? publicId;
  final String sku;
  final String barcodeText;
  final String? expiryDate;
  final String vendorName;
  final String? brandLogoUrl;
  final VendorBarcodeVariant variant;
  final double? weight;
  final String weightUnit;
  final VendorBarcodeCategoryBrief category;
  final VendorBarcodeVendorBrief vendor;

  VendorBarcodeProduct({
    required this.id,
    required this.name,
    required this.barcode,
    required this.sellPrice,
    required this.regularPrice,
    required this.stock,
    required this.image,
    required this.description,
    this.publicId,
    required this.sku,
    required this.barcodeText,
    this.expiryDate,
    required this.vendorName,
    this.brandLogoUrl,
    required this.variant,
    this.weight,
    required this.weightUnit,
    required this.category,
    required this.vendor,
  });

  factory VendorBarcodeProduct.fromJson(Map<String, dynamic> j) {
    final w = j['weight'];
    return VendorBarcodeProduct(
      id: _toInt(j['id']),
      name: _s(j['name']),
      barcode: _s(j['barcode']),
      sellPrice: _toDouble(j['sell_price']),
      regularPrice: _toDouble(j['regular_price']),
      stock: _toInt(j['stock']),
      image: _s(j['image']),
      description: _s(j['description']),
      publicId: _nullableString(j['public_id']),
      sku: _s(j['sku']),
      barcodeText: _s(j['barcode_text']),
      expiryDate: _nullableString(j['expiry_date']),
      vendorName: _s(j['vendor_name']),
      brandLogoUrl: _nullableString(j['brand_logo_url']),
      variant: VendorBarcodeVariant.fromJson(j['variant']),
      weight: w == null ? null : _toDouble(w),
      weightUnit: _s(j['weight_unit']).isEmpty ? 'kg' : _s(j['weight_unit']),
      category: VendorBarcodeCategoryBrief.fromJson(j['category']),
      vendor: VendorBarcodeVendorBrief.fromJson(j['vendor']),
    );
  }
}

class VendorBarcodeListPage {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<VendorBarcodeProduct> items;

  VendorBarcodeListPage({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.items,
  });

  factory VendorBarcodeListPage.empty() => VendorBarcodeListPage(
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: 0,
    items: const [],
  );

  factory VendorBarcodeListPage.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VendorBarcodeListPage.empty();
    final list = (j['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VendorBarcodeProduct.fromJson)
        .toList();
    return VendorBarcodeListPage(
      currentPage: _toInt(j['current_page'], d: 1),
      lastPage: _toInt(j['last_page'], d: 1),
      perPage: _toInt(j['per_page'], d: 20),
      total: _toInt(j['total']),
      items: list,
    );
  }
}

class VendorBarcodeLabelPrintData {
  final String barcode;
  final String barcodeText;
  final String productName;
  final double price;
  final String vendorName;
  final String sku;
  final String? expiryDate;
  final String? brandLogoUrl;
  final VendorBarcodeVariant variant;
  final int copies;

  VendorBarcodeLabelPrintData({
    required this.barcode,
    required this.barcodeText,
    required this.productName,
    required this.price,
    required this.vendorName,
    required this.sku,
    this.expiryDate,
    this.brandLogoUrl,
    required this.variant,
    required this.copies,
  });

  factory VendorBarcodeLabelPrintData.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return VendorBarcodeLabelPrintData(
        barcode: '',
        barcodeText: '',
        productName: '',
        price: 0,
        vendorName: '',
        sku: '',
        expiryDate: null,
        brandLogoUrl: null,
        variant: const VendorBarcodeVariant(),
        copies: 1,
      );
    }
    return VendorBarcodeLabelPrintData(
      barcode: _s(j['barcode']),
      barcodeText: _s(j['barcode_text']),
      productName: _s(j['product_name']),
      price: _toDouble(j['price']),
      vendorName: _s(j['vendor_name']),
      sku: _s(j['sku']),
      expiryDate: _nullableString(j['expiry_date']),
      brandLogoUrl: _nullableString(j['brand_logo_url']),
      variant: VendorBarcodeVariant.fromJson(j['variant']),
      copies: _toInt(j['copies'], d: 1),
    );
  }
}

class VendorBarcodeLabelsResult {
  final VendorBarcodeProduct product;
  final int labelCount;
  final VendorBarcodeLabelPrintData printData;

  VendorBarcodeLabelsResult({
    required this.product,
    required this.labelCount,
    required this.printData,
  });

  factory VendorBarcodeLabelsResult.fromJson(Map<String, dynamic> j) {
    final VendorBarcodeProduct p;
    if (j['product'] is Map<String, dynamic>) {
      p = VendorBarcodeProduct.fromJson(j['product'] as Map<String, dynamic>);
    } else if (j['id'] != null) {
      p = VendorBarcodeProduct.fromJson(j);
    } else {
      p = VendorBarcodeProduct(
        id: 0,
        name: '',
        barcode: '',
        sellPrice: 0,
        regularPrice: 0,
        stock: 0,
        image: '',
        description: '',
        publicId: null,
        sku: '',
        barcodeText: '',
        expiryDate: null,
        vendorName: '',
        brandLogoUrl: null,
        variant: const VendorBarcodeVariant(),
        weight: null,
        weightUnit: 'kg',
        category: const VendorBarcodeCategoryBrief(id: 0, name: ''),
        vendor: const VendorBarcodeVendorBrief(id: 0, businessName: ''),
      );
    }
    return VendorBarcodeLabelsResult(
      product: p,
      labelCount: _toInt(j['label_count'], d: 1),
      printData: VendorBarcodeLabelPrintData.fromJson(
        j['print_data'] is Map<String, dynamic>
            ? j['print_data'] as Map<String, dynamic>
            : null,
      ),
    );
  }
}
