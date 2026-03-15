// Model for GET api/InvoiceProductList/{id} response.

class InvoiceDetailsResponse {
  final String? status;
  final String? message;
  final InvoiceDetails? data;

  InvoiceDetailsResponse({this.status, this.message, this.data});

  factory InvoiceDetailsResponse.fromJson(Map<String, dynamic> json) =>
      InvoiceDetailsResponse(
        status: json['status']?.toString(),
        message: json['message']?.toString(),
        data: json['data'] is Map<String, dynamic>
            ? InvoiceDetails.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}

class InvoiceDetails {
  final int id;
  final String total;
  final String vat;
  final String payable;
  final String? deliveryStatus;
  final String? status;
  final String? transactionId;
  final String? paymentMethod;
  final String? taxRef;
  final String? cusName;
  final String? cusEmail;
  final String? cusPhone;
  final String? currency;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<InvoiceItemDetail> items;

  InvoiceDetails({
    required this.id,
    required this.total,
    required this.vat,
    required this.payable,
    this.deliveryStatus,
    this.status,
    this.transactionId,
    this.paymentMethod,
    this.taxRef,
    this.cusName,
    this.cusEmail,
    this.cusPhone,
    this.currency,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory InvoiceDetails.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return InvoiceDetails(
      id: _toInt(json['id']),
      total: json['total']?.toString() ?? '0',
      vat: json['vat']?.toString() ?? '0',
      payable: json['payable']?.toString() ?? '0',
      deliveryStatus: json['delivery_status']?.toString(),
      status: json['status']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      taxRef: json['tax_ref']?.toString(),
      cusName: json['cus_name']?.toString(),
      cusEmail: json['cus_email']?.toString(),
      cusPhone: json['cus_phone']?.toString(),
      currency: json['currency']?.toString(),
      userId: _toInt(json['user_id']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      items: itemsList
          .map((e) => InvoiceItemDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InvoiceItemDetail {
  final int id;
  final int quantity;
  final String status;
  final String totalPay;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final DateTime? createdAt;
  final InvoiceProductDetail? product;
  final InvoiceVendorDetail? vendor;

  InvoiceItemDetail({
    required this.id,
    required this.quantity,
    required this.status,
    required this.totalPay,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    this.createdAt,
    this.product,
    this.vendor,
  });

  factory InvoiceItemDetail.fromJson(Map<String, dynamic> json) =>
      InvoiceItemDetail(
        id: _toInt(json['id']),
        quantity: _toInt(json['quantity']),
        status: json['status']?.toString() ?? '',
        totalPay: json['total_pay']?.toString() ?? '0',
        invoiceId: _toInt(json['invoice_id']),
        productId: _toInt(json['product_id']),
        vendorId: _toInt(json['vendor_id']),
        createdAt: _toDate(json['created_at']),
        product: json['product'] is Map<String, dynamic>
            ? InvoiceProductDetail.fromJson(
                json['product'] as Map<String, dynamic>)
            : null,
        vendor: json['vendor'] is Map<String, dynamic>
            ? InvoiceVendorDetail.fromJson(
                json['vendor'] as Map<String, dynamic>)
            : null,
      );
}

class InvoiceProductDetail {
  final int id;
  final String name;
  final String? description;
  final String image;
  final String? sellPrice;
  final List<InvoiceProductImage> images;

  InvoiceProductDetail({
    required this.id,
    required this.name,
    this.description,
    required this.image,
    this.sellPrice,
    required this.images,
  });

  factory InvoiceProductDetail.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List? ?? [];
    return InvoiceProductDetail(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString() ?? '',
      sellPrice: json['sell_price']?.toString(),
      images: imagesList
          .map((e) => InvoiceProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InvoiceProductImage {
  final int id;
  final String imagePath;

  InvoiceProductImage({required this.id, required this.imagePath});

  factory InvoiceProductImage.fromJson(Map<String, dynamic> json) =>
      InvoiceProductImage(
        id: _toInt(json['id']),
        imagePath: json['image_path']?.toString() ?? '',
      );
}

class InvoiceVendorDetail {
  final int id;
  final String? businessName;
  final String? address;
  final String? coverImage;

  InvoiceVendorDetail({
    required this.id,
    this.businessName,
    this.address,
    this.coverImage,
  });

  factory InvoiceVendorDetail.fromJson(Map<String, dynamic> json) =>
      InvoiceVendorDetail(
        id: _toInt(json['id']),
        businessName: json['business_name']?.toString(),
        address: json['address']?.toString(),
        coverImage: json['cover_image']?.toString(),
      );
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
