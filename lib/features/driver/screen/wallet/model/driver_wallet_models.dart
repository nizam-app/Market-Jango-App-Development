// Driver wallet models — shapes align with doc/details.md (vendor wallet–like payloads).

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

class DriverOrdersPage<T> {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<T> items;

  const DriverOrdersPage({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.items,
  });

  static DriverOrdersPage<T> parse<T>(
    Map<String, dynamic>? j,
    T Function(Map<String, dynamic>) item,
  ) {
    if (j == null) {
      return const DriverOrdersPage(
        currentPage: 1,
        lastPage: 1,
        perPage: 20,
        total: 0,
        items: [],
      );
    }
    final list = (j['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(item)
        .toList();
    return DriverOrdersPage(
      currentPage: _toInt(j['current_page'], d: 1),
      lastPage: _toInt(j['last_page'], d: 1),
      perPage: _toInt(j['per_page'], d: 20),
      total: _toInt(j['total']),
      items: list,
    );
  }
}

class DriverWalletOverview {
  final Map<String, dynamic> raw;

  DriverWalletOverview(this.raw);

  String get balanceLabel {
    for (final k in ['balance', 'available_balance', 'available', 'total']) {
      if (raw[k] != null) return _s(raw[k]);
    }
    return '—';
  }

  String? get currency => raw['currency']?.toString();

  String get creditedLabel => _s(raw['total_credited']);
  String get debitedLabel => _s(raw['total_debited']);

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

class DriverWalletTransaction {
  final int? id;
  final String type;
  final String amount;
  final String status;
  final String? description;
  final DateTime? createdAt;
  final String? transactionId;

  DriverWalletTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.createdAt,
    this.transactionId,
  });

  factory DriverWalletTransaction.fromJson(Map<String, dynamic> j) {
    final sign = j['amount_sign']?.toString().trim();
    final rawAmt = _s(j['amount']);
    final amt = (sign != null && sign.isNotEmpty) ? '$sign$rawAmt' : rawAmt;
    return DriverWalletTransaction(
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

class DriverPayoutRequest {
  final int id;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime? createdAt;
  final String? note;

  DriverPayoutRequest({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.createdAt,
    this.note,
  });

  factory DriverPayoutRequest.fromJson(Map<String, dynamic> j) {
    return DriverPayoutRequest(
      id: _toInt(j['id']),
      amount: _toDouble(j['amount']),
      status: _s(j['status']),
      paymentMethod: _s(j['payment_method']),
      createdAt: _dt(j['created_at']),
      note: j['note']?.toString(),
    );
  }
}
