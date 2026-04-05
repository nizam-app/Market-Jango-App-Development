// Product payload from vendor barcode APIs (doc/VENDOR_BARCODE_AND_SCANNER_API.md).

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

class VendorBarcodeProduct {
  final int id;
  final String name;
  final String barcode;
  final double sellPrice;
  final double regularPrice;
  final int stock;
  final String image;

  VendorBarcodeProduct({
    required this.id,
    required this.name,
    required this.barcode,
    required this.sellPrice,
    required this.regularPrice,
    required this.stock,
    required this.image,
  });

  factory VendorBarcodeProduct.fromJson(Map<String, dynamic> j) {
    return VendorBarcodeProduct(
      id: _toInt(j['id']),
      name: _s(j['name']),
      barcode: _s(j['barcode']),
      sellPrice: _toDouble(j['sell_price']),
      regularPrice: _toDouble(j['regular_price']),
      stock: _toInt(j['stock']),
      image: _s(j['image']),
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
  final String productName;
  final double price;
  final String vendorName;
  final int copies;

  VendorBarcodeLabelPrintData({
    required this.barcode,
    required this.productName,
    required this.price,
    required this.vendorName,
    required this.copies,
  });

  factory VendorBarcodeLabelPrintData.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return VendorBarcodeLabelPrintData(
        barcode: '',
        productName: '',
        price: 0,
        vendorName: '',
        copies: 1,
      );
    }
    return VendorBarcodeLabelPrintData(
      barcode: _s(j['barcode']),
      productName: _s(j['product_name']),
      price: _toDouble(j['price']),
      vendorName: _s(j['vendor_name']),
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
