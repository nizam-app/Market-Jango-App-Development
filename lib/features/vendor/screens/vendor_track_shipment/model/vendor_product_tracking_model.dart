import 'dart:convert';

/// ============== TOP LEVEL RESPONSE + PAGE ==============

VendorAllOrdersResponse vendorAllOrdersResponseFromJson(String source) =>
    VendorAllOrdersResponse.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );

class VendorAllOrdersResponse {
  final String status;
  final String message;
  final VendorOrdersPage data;

  VendorAllOrdersResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorAllOrdersResponse.fromJson(Map<String, dynamic> j) {
    return VendorAllOrdersResponse(
      status: (j['status'] ?? '').toString(),
      message: (j['message'] ?? '').toString(),
      data: VendorOrdersPage.fromJson(j['data'] as Map<String, dynamic>),
    );
  }
}

class VendorOrdersPage {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<VendorOrderEntity> data;

  VendorOrdersPage({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.data,
  });

  factory VendorOrdersPage.fromJson(Map<String, dynamic> j) {
    final list = (j['data'] as List? ?? [])
        .map((e) => VendorOrderEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    return VendorOrdersPage(
      currentPage: _toInt(j['current_page']),
      lastPage: _toInt(j['last_page']),
      total: _toInt(j['total']),
      data: list,
    );
  }
}

/// ===================== ORDER ENTITY =====================

class VendorOrderEntity {
  final int id;
  final int quantity;
  final String tranId;
  final String status; // "Complete","AssignedOrder","On The Way",...
  final double salePrice;
  final int invoiceId;
  final int productId;
  final int vendorId;
  final int driverId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ShipmentInvoice? invoice;
  final ShipmentProduct? product;
  final ShipmentDriver? driver;

  VendorOrderEntity({
    required this.id,
    required this.quantity,
    required this.tranId,
    required this.status,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    required this.vendorId,
    required this.driverId,
    this.createdAt,
    this.updatedAt,
    this.invoice,
    this.product,
    this.driver,
  });

  factory VendorOrderEntity.fromJson(Map<String, dynamic> j) {
    return VendorOrderEntity(
      id: _toInt(j['id']),
      quantity: _toInt(j['quantity']),
      tranId: (j['tran_id'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      salePrice: _toDouble(j['sale_price']),
      invoiceId: _toInt(j['invoice_id']),
      productId: _toInt(j['product_id']),
      vendorId: _toInt(j['vendor_id']),
      driverId: _toInt(j['driver_id']),
      createdAt: _toDate(j['created_at']),
      updatedAt: _toDate(j['updated_at']),
      invoice: j['invoice'] == null
          ? null
          : ShipmentInvoice.fromJson(j['invoice'] as Map<String, dynamic>),
      product: j['product'] == null
          ? null
          : ShipmentProduct.fromJson(j['product'] as Map<String, dynamic>),
      driver: j['driver'] == null
          ? null
          : ShipmentDriver.fromJson(j['driver'] as Map<String, dynamic>),
    );
  }
}

/// শুধু দরকারি ফিল্ডগুলো নিলাম

class ShipmentInvoice {
  final int id;
  final String cusName;
  final String shipAddress;
  final String shipCity;
  final String pickupAddress;
  final String payable;
  final DateTime? createdAt;

  ShipmentInvoice({
    required this.id,
    required this.cusName,
    required this.shipAddress,
    required this.shipCity,
    required this.pickupAddress,
    required this.payable,
    this.createdAt,
  });

  factory ShipmentInvoice.fromJson(Map<String, dynamic> j) {
    return ShipmentInvoice(
      id: _toInt(j['id']),
      cusName: (j['cus_name'] ?? '').toString(),
      shipAddress: (j['ship_address'] ?? '').toString(),
      shipCity: (j['ship_city'] ?? '').toString(),
      pickupAddress: (j['pickup_address'] ?? '').toString(),
      payable: (j['payable'] ?? '0').toString(),
      createdAt: _toDate(j['created_at']),
    );
  }
}

class ShipmentProduct {
  final int id;
  final String name;
  final String image;

  ShipmentProduct({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ShipmentProduct.fromJson(Map<String, dynamic> j) {
    return ShipmentProduct(
      id: _toInt(j['id']),
      name: (j['name'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
    );
  }
}

class ShipmentDriver {
  final int id;
  final ShipmentDriverUser? user;

  ShipmentDriver({
    required this.id,
    this.user,
  });

  factory ShipmentDriver.fromJson(Map<String, dynamic> j) {
    return ShipmentDriver(
      id: _toInt(j['id']),
      user: j['user'] == null
          ? null
          : ShipmentDriverUser.fromJson(j['user'] as Map<String, dynamic>),
    );
  }
}

class ShipmentDriverUser {
  final int id;
  final String name;

  ShipmentDriverUser({
    required this.id,
    required this.name,
  });

  factory ShipmentDriverUser.fromJson(Map<String, dynamic> j) {
    return ShipmentDriverUser(
      id: _toInt(j['id']),
      name: (j['name'] ?? '').toString(),
    );
  }
}

/// ===================== STATUS + UI MODEL =====================

/// Tab গুলো: All + sob status
enum TrackingOrderStatus {
  all,
  pending,
  assigned,
  onTheWay,
  completed,
  cancelled,
}

extension TrackingOrderStatusX on TrackingOrderStatus {
  String get label => switch (this) {
    TrackingOrderStatus.all => 'All',
    TrackingOrderStatus.pending => 'Pending',
    TrackingOrderStatus.assigned => 'Assigned',
    TrackingOrderStatus.onTheWay => 'On the way',
    TrackingOrderStatus.completed => 'Completed',
    TrackingOrderStatus.cancelled => 'Cancelled',
  };
}

class ShipmentItem {
  final String orderNo;
  final String title;
  final String customer;
  final String address;
  final int qty;
  final String date;
  final double price;
  final String imageUrl;
  final TrackingOrderStatus status;

  // extra info for AssignedOrder card
  final String driverName;
  final String pickupLocation;
  final String destinationName;
  final String rawStatus;

  const ShipmentItem({
    required this.orderNo,
    required this.title,
    required this.customer,
    required this.address,
    required this.qty,
    required this.date,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.driverName,
    required this.pickupLocation,
    required this.destinationName,
    required this.rawStatus,
  });

  factory ShipmentItem.fromEntity(VendorOrderEntity e) {
    final inv = e.invoice;
    final prod = e.product;
    final driverUser = e.driver?.user;

    final orderNo = e.tranId.isNotEmpty
        ? e.tranId
        : (inv != null && inv.id != 0 ? inv.id.toString() : e.id.toString());

    final productName = prod?.name ?? 'Product #${e.productId}';
    final title = '$productName x${e.quantity}';

    final customer = inv?.cusName ?? '';
    final address = inv == null
        ? ''
        : '${inv.shipAddress}'
        '${inv.shipCity.isNotEmpty ? ', ${inv.shipCity}' : ''}';

    final created = e.createdAt ?? inv?.createdAt;
    final date = created == null
        ? ''
        : '${created.day.toString().padLeft(2, '0')} '
        '${_monthName(created.month)} ${created.year}';

    final price = e.salePrice != 0
        ? e.salePrice
        : double.tryParse(inv?.payable ?? '0') ?? 0.0;

    final imageUrl = prod?.image ??
        'https://via.placeholder.com/200x200.png?text=Product';

    final pickupLocation = inv?.pickupAddress ?? '';
    final destinationName = inv?.cusName ?? '';
    final driverName = driverUser?.name ?? '';

    return ShipmentItem(
      orderNo: orderNo,
      title: title,
      customer: customer,
      address: address,
      qty: e.quantity,
      date: date,
      price: price,
      imageUrl: imageUrl,
      status: _statusFromApi(e.status),
      driverName: driverName,
      pickupLocation: pickupLocation,
      destinationName: destinationName,
      rawStatus: e.status,
    );
  }
}

/// ===================== RIVERPOD STATE MODEL =====================

class VendorShipmentsState {
  final List<ShipmentItem> allItems;
  final TrackingOrderStatus status; // current tab
  final int segment; // segmented toggle
  final String query;
  final int? selectedIndex;

  const VendorShipmentsState({
    required this.allItems,
    required this.status,
    required this.segment,
    required this.query,
    required this.selectedIndex,
  });

  List<ShipmentItem> get filtered {
    final q = query.trim().toLowerCase();

    Iterable<ShipmentItem> list = allItems;

    // All হলে filter hobena, otherwise status diye filter
    if (status != TrackingOrderStatus.all) {
      list = list.where((e) => e.status == status);
    }

    return list.where((e) {
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.customer.toLowerCase().contains(q) ||
          e.orderNo.toLowerCase().contains(q);
    }).toList();
  }

  VendorShipmentsState copyWith({
    List<ShipmentItem>? allItems,
    TrackingOrderStatus? status,
    int? segment,
    String? query,
    int? selectedIndex,
  }) {
    return VendorShipmentsState(
      allItems: allItems ?? this.allItems,
      status: status ?? this.status,
      segment: segment ?? this.segment,
      query: query ?? this.query,
      selectedIndex: selectedIndex,
    );
  }

  static VendorShipmentsState initial() => const VendorShipmentsState(
    allItems: [],
    status: TrackingOrderStatus.all, // first tab = All
    segment: 0,
    query: '',
    selectedIndex: null,
  );
}

/// ===================== HELPERS =====================

TrackingOrderStatus _statusFromApi(String raw) {
  final s = raw.toLowerCase().trim();

  if (s.contains('assign')) return TrackingOrderStatus.assigned;
  if (s.contains('on the way')) return TrackingOrderStatus.onTheWay;
  if (s.contains('complete')) return TrackingOrderStatus.completed;
  if (s.contains('cancel')) return TrackingOrderStatus.cancelled;
  if (s.contains('pending')) return TrackingOrderStatus.pending;

  return TrackingOrderStatus.pending;
}

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

String _monthName(int m) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return (m >= 1 && m <= 12) ? names[m] : '';
}