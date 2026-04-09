// providers/driver_all_orders_provider.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_model.dart';

final driverAllOrdersProvider =
    AsyncNotifierProvider<DriverAllOrdersNotifier, DriverAllOrdersResponse?>(
      DriverAllOrdersNotifier.new,
    );

/// Uses JSON `message` when present (e.g. `{ "status":"failed", "message":"Driver not found" }`).
String _driverOrdersHttpError(int code, String body) {
  final t = body.trim();
  if (t.isNotEmpty) {
    try {
      final j = jsonDecode(t);
      if (j is Map<String, dynamic>) {
        final msg = j['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty) return msg;
      }
    } catch (_) {}
  }
  if (code == 401 || code == 403) return 'Session expired. Please sign in again.';
  if (code == 404) return 'Driver not found. Contact support if you are registered as a driver.';
  return 'Could not load orders (HTTP $code).';
}

class DriverAllOrdersNotifier extends AsyncNotifier<DriverAllOrdersResponse?> {
  int _page = 1;

  // ডাইনামিক ট্যাব লেবেল (API status থেকে)
  List<String> _statusTabs = const ['All'];
  List<String> get statusTabs => _statusTabs;

  @override
  Future<DriverAllOrdersResponse?> build() async {
    _page = 1;
    final res = await _fetch(_page);
    _rebuildTabsFrom(res); // শুধু order.status দিয়ে
    return res;
  }

  int get currentPage => state.value?.data.currentPage ?? 1;
  int get lastPage => state.value?.data.lastPage ?? 1;

  Future<void> changePage(int page) async {
    if (page < 1) return;
    _page = page;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() => _fetch(_page));
    state = next;
    final val = next.valueOrNull;
    if (val != null) _rebuildTabsFrom(val);
  }

  Future<DriverAllOrdersResponse> _fetch(int page) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final url = DriverAPIController.allOrders(page: page);
    final r = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'token': token},
    );
    if (r.statusCode != 200) {
      throw Exception(_driverOrdersHttpError(r.statusCode, r.body));
    }
    final parsed = driverAllOrdersResponseFromJson(r.body);
    final st = parsed.status.toLowerCase();
    if (st == 'failed' || st == 'error') {
      final m = parsed.message?.trim();
      throw Exception(
        (m != null && m.isNotEmpty) ? m : 'Could not load orders.',
      );
    }
    return parsed;
  }

  /* ---------- UI mapping: কেবল order.status ---------- */

  // UI item list
  List<OrderItem> toUi({String query = '', int tabIndex = 0}) {
    final rows = state.value?.data.data ?? const <DriverOrderEntity>[];
    var items = rows.map(_toOrderItem).toList();

    // Search (orderId = invoice.tax_ref / tran_id / id)
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items.where((e) => e.orderId.toLowerCase().contains(q)).toList();
    }

    // Tab filter (label ঠিক যেটা দেখাচ্ছি সেটাই ধরে ফিল্টার)
    final tabs = statusTabs;
    final label = (tabIndex >= 0 && tabIndex < tabs.length)
        ? tabs[tabIndex]
        : 'All';
    if (label != 'All') {
      final want = _norm(label);
      items = items.where((e) => _norm(e.statusLabel) == want).toList();
    }

    return items;
  }

  // API response থেকে ডাইনামিক ট্যাব বানানো (শুধু e.status)
  // API response থেকে ডাইনামিক ট্যাব বানানো (শুধু e.status দিয়ে)
  void _rebuildTabsFrom(DriverAllOrdersResponse res) {
    final rows = res.data.data;
    final map = <String, String>{}; // norm -> original label

    for (final e in rows) {
      final raw = (e.status).toString().trim();
      if (raw.isEmpty) continue;

      final norm = _norm(raw);

      // ❌ "pending" ke tab hisebe dekhabo na
      if (norm == 'pending') continue;

      // same status jeno ekbar e add hoy
      map.putIfAbsent(norm, () => raw);
    }

    // simple order: All + je je status paichi
    _statusTabs = ['All', ...map.values];
  }

  // Entity -> UI
  OrderItem _toOrderItem(DriverOrderEntity e) {
    final inv = e.invoice;

    // UI তে show করার জন্য orderId (taxRef / tranId / fallback e.id)
    final orderId = (inv?.taxRef.isNotEmpty == true)
        ? inv!.taxRef
        : (e.tranId.isNotEmpty ? e.tranId : e.id.toString());

    final pickup = e.pickupAddress.isNotEmpty == true ? e.pickupAddress : '-';

    final dest = e.shipAddress.isNotEmpty == true ? e.shipAddress : '-';

    final price = e.salePrice != 0 ? e.salePrice : _safeDouble(inv?.payable);

    final label = (e.status).toString().trim();
    final kind = _classifyByLabel(label);

    return OrderItem(
      driverOrderId: e.id, // 👈 এখানে DriverOrderEntity.id সেভ করলাম
      orderId: orderId, // 👈 শুধু display/search এর জন্য
      pickup: pickup,
      destination: dest,
      price: price,
      statusLabel: label,
      kind: kind,
    );
  }
}

/* ===== UI-side model ===== */

enum OrderStatus { delivered, pending, onTheWay }

class OrderItem {
  /// 👇 এটা হবে DriverOrderEntity.id
  final int driverOrderId;

  /// display / search এর জন্য invoice.tax_ref / tran_id / ...
  final String orderId;

  final String pickup;
  final String destination;
  final double price;
  final String statusLabel; // ← API-র status
  final OrderStatus kind;

  const OrderItem({
    required this.driverOrderId,
    required this.orderId,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.statusLabel,
    required this.kind,
  });
}

/* helpers */
String _norm(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

OrderStatus _classifyByLabel(String label) {
  final s = _norm(label);
  if (s.contains('complete') || s.contains('delivered')) {
    return OrderStatus.delivered;
  }
  if (s.contains('assign') || s.contains('on the way') || s.contains('way')) {
    return OrderStatus.onTheWay;
  }
  // অন্য যেকোনো status default → pending color
  return OrderStatus.pending;
}

double _safeDouble(String? s) => s == null ? 0.0 : (double.tryParse(s) ?? 0.0);
