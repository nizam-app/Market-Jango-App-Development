// Models for vendor order management APIs (flexible JSON — backend may vary slightly).

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

DateTime? _dt(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

/// Laravel-style paginated payload under `data`.
class VendorOrdersPage<T> {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<T> items;

  const VendorOrdersPage({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.items,
  });

  static VendorOrdersPage<T> parse<T>(
    Map<String, dynamic>? j,
    T Function(Map<String, dynamic>) item,
  ) {
    if (j == null) {
      return const VendorOrdersPage(
        currentPage: 1,
        lastPage: 1,
        perPage: 10,
        total: 0,
        items: [],
      );
    }
    final list = (j['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(item)
        .toList();
    return VendorOrdersPage(
      currentPage: _toInt(j['current_page'], d: 1),
      lastPage: _toInt(j['last_page'], d: 1),
      perPage: _toInt(j['per_page'], d: 10),
      total: _toInt(j['total']),
      items: list,
    );
  }
}

class VendorNestedInvoice {
  final int id;
  final String orderNumber;
  final String status;
  final String? paymentMethod;
  final String? cusName;
  final bool? isManualOrder;

  VendorNestedInvoice({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.paymentMethod,
    this.cusName,
    this.isManualOrder,
  });

  factory VendorNestedInvoice.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return VendorNestedInvoice(id: 0, orderNumber: '', status: '');
    }
    final manual = j['is_manual_order'];
    return VendorNestedInvoice(
      id: _toInt(j['id']),
      orderNumber: _s(j['order_number']),
      status: _s(j['status']),
      paymentMethod: j['payment_method']?.toString(),
      cusName: j['cus_name']?.toString(),
      isManualOrder: manual == null
          ? null
          : (manual == true ||
              manual == 1 ||
              manual.toString().toLowerCase() == 'true' ||
              manual.toString() == '1'),
    );
  }
}

class VendorNestedProduct {
  final int id;
  final String name;

  VendorNestedProduct({required this.id, required this.name});

  factory VendorNestedProduct.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VendorNestedProduct(id: 0, name: '');
    return VendorNestedProduct(id: _toInt(j['id']), name: _s(j['name']));
  }
}

class VendorNestedDriver {
  final int id;
  final String name;

  VendorNestedDriver({required this.id, required this.name});

  factory VendorNestedDriver.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VendorNestedDriver(id: 0, name: '');
    final user = j['user'] is Map<String, dynamic>
        ? j['user'] as Map<String, dynamic>
        : null;
    return VendorNestedDriver(
      id: _toInt(j['id']),
      name: _s(user?['name'] ?? j['name']),
    );
  }
}

/// One marketplace `invoice_item` row from `GET /vendor/orders`.
class VendorMarketplaceLine {
  final int id;
  final int quantity;
  final String status;
  final double salePrice;
  final int invoiceId;
  final int productId;
  final DateTime? createdAt;
  final VendorNestedInvoice invoice;
  final VendorNestedProduct product;
  final VendorNestedDriver? driver;

  /// Line-level fields when API returns full `invoice_item` objects.
  final String? lineCustomerName;
  final String? shipAddress;
  final String? pickupAddress;
  final String? linePaymentMethod;
  final String? totalPay;
  final String? unitPrice;
  final String? lineNote;

  VendorMarketplaceLine({
    required this.id,
    required this.quantity,
    required this.status,
    required this.salePrice,
    required this.invoiceId,
    required this.productId,
    this.createdAt,
    required this.invoice,
    required this.product,
    this.driver,
    this.lineCustomerName,
    this.shipAddress,
    this.pickupAddress,
    this.linePaymentMethod,
    this.totalPay,
    this.unitPrice,
    this.lineNote,
  });

  factory VendorMarketplaceLine.fromJson(Map<String, dynamic> j) {
    return VendorMarketplaceLine(
      id: _toInt(j['id']),
      quantity: _toInt(j['quantity'], d: 1),
      status: _s(j['status']),
      salePrice: _toDouble(j['sale_price']),
      invoiceId: _toInt(j['invoice_id']),
      productId: _toInt(j['product_id']),
      createdAt: _dt(j['created_at']),
      invoice: VendorNestedInvoice.fromJson(
        j['invoice'] is Map<String, dynamic>
            ? j['invoice'] as Map<String, dynamic>
            : null,
      ),
      product: VendorNestedProduct.fromJson(
        j['product'] is Map<String, dynamic>
            ? j['product'] as Map<String, dynamic>
            : null,
      ),
      driver: j['driver'] is Map<String, dynamic>
          ? VendorNestedDriver.fromJson(j['driver'] as Map<String, dynamic>)
          : null,
      lineCustomerName: j['cus_name']?.toString(),
      shipAddress: j['ship_address']?.toString(),
      pickupAddress: j['pickup_address']?.toString(),
      linePaymentMethod: j['payment_method']?.toString(),
      totalPay: j['total_pay']?.toString(),
      unitPrice: j['unit_price']?.toString(),
      lineNote: j['note']?.toString(),
    );
  }
}

class VendorMarketplaceLineDetail extends VendorMarketplaceLine {
  final List<String> allowedNextStatuses;

  VendorMarketplaceLineDetail({
    required super.id,
    required super.quantity,
    required super.status,
    required super.salePrice,
    required super.invoiceId,
    required super.productId,
    super.createdAt,
    required super.invoice,
    required super.product,
    super.driver,
    super.lineCustomerName,
    super.shipAddress,
    super.pickupAddress,
    super.linePaymentMethod,
    super.totalPay,
    super.unitPrice,
    super.lineNote,
    required this.allowedNextStatuses,
  });

  factory VendorMarketplaceLineDetail.fromJson(Map<String, dynamic> j) {
    final base = VendorMarketplaceLine.fromJson(j);
    final raw = j['allowed_next_statuses'];
    final next = raw is List
        ? raw.map((e) => e.toString()).toList()
        : <String>[];
    return VendorMarketplaceLineDetail(
      id: base.id,
      quantity: base.quantity,
      status: base.status,
      salePrice: base.salePrice,
      invoiceId: base.invoiceId,
      productId: base.productId,
      createdAt: base.createdAt,
      invoice: base.invoice,
      product: base.product,
      driver: base.driver,
      lineCustomerName: base.lineCustomerName,
      shipAddress: base.shipAddress,
      pickupAddress: base.pickupAddress,
      linePaymentMethod: base.linePaymentMethod,
      totalPay: base.totalPay,
      unitPrice: base.unitPrice,
      lineNote: base.lineNote,
      allowedNextStatuses: next,
    );
  }
}

class OrderSummary {
  final String total;
  final String payable;
  final String? vat;
  final String? customerPaid;
  final String? change;

  OrderSummary({
    required this.total,
    required this.payable,
    this.vat,
    this.customerPaid,
    this.change,
  });

  factory OrderSummary.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return OrderSummary(total: '0', payable: '0');
    }
    return OrderSummary(
      total: _s(j['total']),
      payable: _s(j['payable']),
      vat: j['vat']?.toString(),
      customerPaid: j['customer_paid']?.toString(),
      change: j['change']?.toString(),
    );
  }
}

class VendorManualLineItem {
  final int id;
  final int productId;
  final int quantity;
  final String status;
  final String? productName;

  VendorManualLineItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.status,
    this.productName,
  });

  factory VendorManualLineItem.fromJson(Map<String, dynamic> j) {
    final p = j['product'] is Map<String, dynamic>
        ? j['product'] as Map<String, dynamic>
        : null;
    return VendorManualLineItem(
      id: _toInt(j['id']),
      productId: _toInt(j['product_id']),
      quantity: _toInt(j['quantity'], d: 1),
      status: _s(j['status']),
      productName: p != null ? _s(p['name']) : null,
    );
  }
}

class VendorManualOrderInvoice {
  final int id;
  final String orderNumber;
  final String status;
  final String? paymentMethod;
  final String? customerName;
  final String? customerPhone;
  final DateTime? createdAt;
  final List<VendorManualLineItem> items;
  final OrderSummary summary;

  VendorManualOrderInvoice({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.createdAt,
    required this.items,
    required this.summary,
  });

  factory VendorManualOrderInvoice.fromJson(Map<String, dynamic> j) {
    final items = (j['items'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VendorManualLineItem.fromJson)
        .toList();
    return VendorManualOrderInvoice(
      id: _toInt(j['id']),
      orderNumber: _s(j['order_number']),
      status: _s(j['status']),
      paymentMethod: j['payment_method']?.toString(),
      customerName: j['customer_name']?.toString(),
      customerPhone: j['customer_phone']?.toString(),
      createdAt: _dt(j['created_at']),
      items: items,
      summary: OrderSummary.fromJson(
        j['summary'] is Map<String, dynamic>
            ? j['summary'] as Map<String, dynamic>
            : null,
      ),
    );
  }
}

class VendorOrderStatusesPayload {
  final List<String> statuses;
  final Map<String, List<String>> transitions;

  VendorOrderStatusesPayload({
    required this.statuses,
    required this.transitions,
  });

  factory VendorOrderStatusesPayload.empty() =>
      VendorOrderStatusesPayload(statuses: const [], transitions: const {});

  factory VendorOrderStatusesPayload.fromJson(Map<String, dynamic>? j) {
    if (j == null) return VendorOrderStatusesPayload.empty();
    List<String> statuses = [];
    final s = j['statuses'];
    if (s is List) {
      statuses = s.map((e) => e.toString()).toList();
    }
    final Map<String, List<String>> trans = {};
    final t = j['transitions'];
    if (t is Map) {
      t.forEach((k, v) {
        if (v is List) {
          trans[k.toString()] = v.map((e) => e.toString()).toList();
        }
      });
    }
    return VendorOrderStatusesPayload(statuses: statuses, transitions: trans);
  }
}

/// Wallet overview — keep raw map for unknown backend fields.
class VendorWalletOverview {
  final Map<String, dynamic> raw;

  VendorWalletOverview(this.raw);

  String get balanceLabel {
    for (final k in ['balance', 'available_balance', 'available', 'total']) {
      if (raw[k] != null) return _s(raw[k]);
    }
    return '—';
  }

  String? get currency => raw['currency']?.toString();

  String get creditedLabel => _s(raw['total_credited']);
  String get debitedLabel => _s(raw['total_debited']);

  /// Parsed balance for payout validation (same keys as [balanceLabel]).
  num? get balanceNumeric {
    for (final k in ['balance', 'available_balance', 'available', 'total']) {
      final v = raw[k];
      if (v == null) continue;
      if (v is num) return v;
      final p = num.tryParse(v.toString().replaceAll(',', ''));
      if (p != null) return p;
    }
    return null;
  }
}

class VendorWalletTransaction {
  final int? id;
  final String type;
  final String amount;
  final String status;
  final String? description;
  final DateTime? createdAt;
  final String? transactionId;

  VendorWalletTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.createdAt,
    this.transactionId,
  });

  factory VendorWalletTransaction.fromJson(Map<String, dynamic> j) {
    final sign = j['amount_sign']?.toString().trim();
    final rawAmt = _s(j['amount']);
    final amt = (sign != null && sign.isNotEmpty) ? '$sign$rawAmt' : rawAmt;
    return VendorWalletTransaction(
      id: j['id'] != null ? _toInt(j['id']) : null,
      type: _s(j['type']),
      amount: amt,
      status: _s(j['status']),
      description: j['description']?.toString(),
      createdAt: _dt(j['date']) ?? _dt(j['created_at']),
      transactionId: j['transaction_id']?.toString(),
    );
  }
}

/// `GET /vendor/wallet/payouts` row.
class VendorPayoutRequest {
  final int id;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime? createdAt;
  final String? note;

  VendorPayoutRequest({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.createdAt,
    this.note,
  });

  factory VendorPayoutRequest.fromJson(Map<String, dynamic> j) {
    return VendorPayoutRequest(
      id: _toInt(j['id']),
      amount: _toDouble(j['amount']),
      status: _s(j['status']),
      paymentMethod: _s(j['payment_method']),
      createdAt: _dt(j['created_at']),
      note: j['note']?.toString(),
    );
  }
}

class VendorRefundBucket {
  final int count;
  final double total;

  const VendorRefundBucket({this.count = 0, this.total = 0});

  factory VendorRefundBucket.fromJson(dynamic v) {
    if (v is! Map<String, dynamic>) {
      return const VendorRefundBucket();
    }
    return VendorRefundBucket(
      count: _toInt(v['count']),
      total: _toDouble(v['total']),
    );
  }
}

class VendorRefundSummary {
  final VendorRefundBucket pending;
  final VendorRefundBucket approved;
  final VendorRefundBucket rejected;

  VendorRefundSummary({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory VendorRefundSummary.fromJson(Map<String, dynamic> j) {
    return VendorRefundSummary(
      pending: VendorRefundBucket.fromJson(j['pending']),
      approved: VendorRefundBucket.fromJson(j['approved']),
      rejected: VendorRefundBucket.fromJson(j['rejected']),
    );
  }
}

class VendorRefundListItem {
  final int id;
  final String status;
  final double amount;
  final String reason;
  final String productName;
  final String customerName;
  final String orderNumber;

  VendorRefundListItem({
    required this.id,
    required this.status,
    required this.amount,
    required this.reason,
    required this.productName,
    required this.customerName,
    required this.orderNumber,
  });

  factory VendorRefundListItem.fromJson(Map<String, dynamic> j) {
    final item = j['invoice_item'] is Map<String, dynamic>
        ? j['invoice_item'] as Map<String, dynamic>
        : null;
    final product = item?['product'] is Map<String, dynamic>
        ? item!['product'] as Map<String, dynamic>
        : null;
    Map<String, dynamic>? inv = item?['invoice'] is Map<String, dynamic>
        ? item!['invoice'] as Map<String, dynamic>
        : null;
    inv ??=
        j['invoice'] is Map<String, dynamic> ? j['invoice'] as Map<String, dynamic> : null;
    final user =
        j['user'] is Map<String, dynamic> ? j['user'] as Map<String, dynamic> : null;
    return VendorRefundListItem(
      id: _toInt(j['id']),
      status: _s(j['status']),
      amount: _toDouble(j['amount']),
      reason: _s(j['reason']),
      productName: _s(product?['name']),
      customerName: _s(user?['name']),
      orderNumber: _s(inv?['order_number']),
    );
  }
}

class VendorRefundsPayload {
  final VendorRefundSummary? summary;
  final VendorOrdersPage<VendorRefundListItem> refunds;

  VendorRefundsPayload({required this.summary, required this.refunds});

  static VendorRefundsPayload parse(Map<String, dynamic>? data) {
    if (data == null) {
      return VendorRefundsPayload(
        summary: null,
        refunds: _emptyRefundPage(),
      );
    }
    VendorRefundSummary? summary;
    final s = data['summary'];
    if (s is Map<String, dynamic>) {
      summary = VendorRefundSummary.fromJson(s);
    }
    Map<String, dynamic>? pageMap;
    final r = data['refunds'];
    if (r is Map<String, dynamic>) pageMap = r;
    final page = VendorOrdersPage.parse(
      pageMap,
      VendorRefundListItem.fromJson,
    );
    return VendorRefundsPayload(summary: summary, refunds: page);
  }

  static VendorOrdersPage<VendorRefundListItem> _emptyRefundPage() {
    return const VendorOrdersPage(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 0,
      items: [],
    );
  }
}

class VendorRefundDetail {
  final int id;
  final String status;
  final double amount;
  final String reason;
  final String? reviewNote;
  final String? requestedBy;
  final String productName;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final String? reviewerName;

  VendorRefundDetail({
    required this.id,
    required this.status,
    required this.amount,
    required this.reason,
    this.reviewNote,
    this.requestedBy,
    required this.productName,
    required this.orderNumber,
    required this.customerName,
    this.customerPhone,
    this.reviewerName,
  });

  factory VendorRefundDetail.fromJson(Map<String, dynamic> j) {
    final item = j['invoice_item'] is Map<String, dynamic>
        ? j['invoice_item'] as Map<String, dynamic>
        : null;
    final product = item?['product'] is Map<String, dynamic>
        ? item!['product'] as Map<String, dynamic>
        : null;
    Map<String, dynamic>? inv = item?['invoice'] is Map<String, dynamic>
        ? item!['invoice'] as Map<String, dynamic>
        : null;
    inv ??=
        j['invoice'] is Map<String, dynamic> ? j['invoice'] as Map<String, dynamic> : null;
    final user =
        j['user'] is Map<String, dynamic> ? j['user'] as Map<String, dynamic> : null;
    final reviewer =
        j['reviewer'] is Map<String, dynamic> ? j['reviewer'] as Map<String, dynamic> : null;
    return VendorRefundDetail(
      id: _toInt(j['id']),
      status: _s(j['status']),
      amount: _toDouble(j['amount']),
      reason: _s(j['reason']),
      reviewNote: j['review_note']?.toString(),
      requestedBy: j['requested_by']?.toString(),
      productName: _s(product?['name']),
      orderNumber: _s(inv?['order_number']),
      customerName: _s(user?['name']),
      customerPhone: user?['phone']?.toString(),
      reviewerName: reviewer?['name']?.toString(),
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';
}
