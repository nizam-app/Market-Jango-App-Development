int _toInt(dynamic v, {int d = 0}) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? d;
}

String _s(dynamic v) => v?.toString() ?? '';

/// Paginated list from `GET /api/driver/deliveries`.
class DriverAssignmentsPage {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<DriverAssignmentRow> items;

  const DriverAssignmentsPage({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.items,
  });

  static DriverAssignmentsPage parse(Map<String, dynamic>? j) {
    if (j == null) {
      return const DriverAssignmentsPage(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
        items: [],
      );
    }
    final list = (j['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(DriverAssignmentRow.fromJson)
        .toList();
    return DriverAssignmentsPage(
      currentPage: _toInt(j['current_page'], d: 1),
      lastPage: _toInt(j['last_page'], d: 1),
      perPage: _toInt(j['per_page'], d: 15),
      total: _toInt(j['total']),
      items: list,
    );
  }
}

/// One row in the deliveries list / detail payload.
class DriverAssignmentRow {
  final int id;
  final String status;
  final Map<String, dynamic> raw;

  DriverAssignmentRow({
    required this.id,
    required this.status,
    required this.raw,
  });

  factory DriverAssignmentRow.fromJson(Map<String, dynamic> j) {
    return DriverAssignmentRow(
      id: _toInt(j['id']),
      status: _s(j['status']).toLowerCase(),
      raw: Map<String, dynamic>.from(j),
    );
  }

  String get displaySubtitle {
    final item = raw['invoice_item'];
    if (item is Map<String, dynamic>) {
      final inv = item['invoice'];
      if (inv is Map<String, dynamic>) {
        final pick = _s(inv['pickup_address']).trim();
        final drop = _s(inv['drop_of_address']).trim();
        if (pick.isNotEmpty || drop.isNotEmpty) {
          return '${pick.isNotEmpty ? pick : "—"} → ${drop.isNotEmpty ? drop : "—"}';
        }
      }
      final prod = item['product'];
      if (prod is Map<String, dynamic>) {
        final name = _s(prod['name']).trim();
        if (name.isNotEmpty) return name;
      }
    }
    return 'Assignment #$id';
  }
}
