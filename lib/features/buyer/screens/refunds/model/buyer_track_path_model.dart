/// `GET /api/buyer/orders/{order_id}/track/path` — `doc/details.md` §10.
class BuyerTrackPathKey {
  const BuyerTrackPathKey({
    required this.invoiceId,
    required this.itemId,
  });

  final int invoiceId;
  /// `invoice_items.id` — required for multi-line invoices.
  final int itemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerTrackPathKey &&
          invoiceId == other.invoiceId &&
          itemId == other.itemId;

  @override
  int get hashCode => Object.hash(invoiceId, itemId);
}

class BuyerTrackPathPoint {
  const BuyerTrackPathPoint({
    required this.latitude,
    required this.longitude,
    this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final String? recordedAt;

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static BuyerTrackPathPoint? tryParse(Map<String, dynamic> m) {
    final lat = _toDouble(m['latitude']);
    final lng = _toDouble(m['longitude']);
    if (lat == null || lng == null) return null;
    return BuyerTrackPathPoint(
      latitude: lat,
      longitude: lng,
      recordedAt: m['recorded_at']?.toString(),
    );
  }
}

class BuyerTrackPathData {
  const BuyerTrackPathData({
    required this.orderId,
    required this.itemId,
    required this.assignmentId,
    required this.status,
    required this.points,
  });

  final int orderId;
  final int? itemId;
  final int? assignmentId;
  final String? status;
  final List<BuyerTrackPathPoint> points;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory BuyerTrackPathData.fromJson(Map<String, dynamic> j) {
    final rawPath = j['path'];
    final points = <BuyerTrackPathPoint>[];
    if (rawPath is List) {
      for (final e in rawPath) {
        if (e is Map<String, dynamic>) {
          final p = BuyerTrackPathPoint.tryParse(e);
          if (p != null) points.add(p);
        } else if (e is Map) {
          final p = BuyerTrackPathPoint.tryParse(Map<String, dynamic>.from(e));
          if (p != null) points.add(p);
        }
      }
    }
    return BuyerTrackPathData(
      orderId: _toInt(j['order_id']),
      itemId: j['item_id'] != null ? _toInt(j['item_id']) : null,
      assignmentId: j['assignment_id'] != null ? _toInt(j['assignment_id']) : null,
      status: j['status']?.toString(),
      points: points,
    );
  }
}
