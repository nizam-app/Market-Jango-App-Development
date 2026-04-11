import 'package:market_jango/features/buyer/screens/wallet/model/buyer_wallet_models.dart';

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

class BuyerRefundListItem {
  final int id;
  final String status;
  final double amount;
  final String reason;
  final String productName;
  final String customerName;
  final String orderNumber;

  BuyerRefundListItem({
    required this.id,
    required this.status,
    required this.amount,
    required this.reason,
    required this.productName,
    required this.customerName,
    required this.orderNumber,
  });

  factory BuyerRefundListItem.fromJson(Map<String, dynamic> j) {
    final item = j['invoice_item'] is Map<String, dynamic>
        ? j['invoice_item'] as Map<String, dynamic>
        : null;
    final product = item?['product'] is Map<String, dynamic>
        ? item!['product'] as Map<String, dynamic>
        : null;
    Map<String, dynamic>? inv = item?['invoice'] is Map<String, dynamic>
        ? item!['invoice'] as Map<String, dynamic>
        : null;
    inv ??= j['invoice'] is Map<String, dynamic>
        ? j['invoice'] as Map<String, dynamic>
        : null;
    final user =
        j['user'] is Map<String, dynamic> ? j['user'] as Map<String, dynamic> : null;
    return BuyerRefundListItem(
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

class BuyerRefundsPayload {
  final BuyerWalletPage<BuyerRefundListItem> refunds;

  BuyerRefundsPayload({required this.refunds});

  static BuyerRefundsPayload parse(Map<String, dynamic>? data) {
    if (data == null) {
      return BuyerRefundsPayload(refunds: _emptyRefundPage());
    }
    Map<String, dynamic>? pageMap;
    final r = data['refunds'];
    if (r is Map<String, dynamic>) {
      // Nested shape: data.refunds = { current_page, data: [...] }
      pageMap = r;
    } else if (data['data'] is List || data['current_page'] != null) {
      // Laravel paginator returned directly as top-level `data` (no refunds key)
      pageMap = data;
    }
    final page = BuyerWalletPage.parse(
      pageMap,
      BuyerRefundListItem.fromJson,
    );
    return BuyerRefundsPayload(refunds: page);
  }

  static BuyerWalletPage<BuyerRefundListItem> _emptyRefundPage() {
    return const BuyerWalletPage(
      currentPage: 1,
      lastPage: 1,
      perPage: 15,
      total: 0,
      items: [],
    );
  }
}

class BuyerRefundDetail {
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

  BuyerRefundDetail({
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

  factory BuyerRefundDetail.fromJson(Map<String, dynamic> j) {
    final item = j['invoice_item'] is Map<String, dynamic>
        ? j['invoice_item'] as Map<String, dynamic>
        : null;
    final product = item?['product'] is Map<String, dynamic>
        ? item!['product'] as Map<String, dynamic>
        : null;
    Map<String, dynamic>? inv = item?['invoice'] is Map<String, dynamic>
        ? item!['invoice'] as Map<String, dynamic>
        : null;
    inv ??= j['invoice'] is Map<String, dynamic>
        ? j['invoice'] as Map<String, dynamic>
        : null;
    final user =
        j['user'] is Map<String, dynamic> ? j['user'] as Map<String, dynamic> : null;
    final reviewer =
        j['reviewer'] is Map<String, dynamic> ? j['reviewer'] as Map<String, dynamic> : null;
    return BuyerRefundDetail(
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
