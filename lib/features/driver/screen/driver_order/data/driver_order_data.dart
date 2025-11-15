// providers/driver_all_orders_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_model.dart';

final driverAllOrdersProvider =
    AsyncNotifierProvider<DriverAllOrdersNotifier, DriverAllOrdersResponse?>(
      DriverAllOrdersNotifier.new,
    );

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
      throw Exception('Fetch failed: ${r.statusCode} ${r.body}');
    }
    return driverAllOrdersResponseFromJson(r.body);
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
  void _rebuildTabsFrom(DriverAllOrdersResponse res) {
    final rows = res.data.data;
    final map = <String, String>{}; // norm -> original
    for (final e in rows) {
      final raw = (e.status).toString().trim();
      if (raw.isEmpty) continue;
      final k = _norm(raw);
      map.putIfAbsent(k, () => raw); // প্রথমবারের ক্যাপশনটাই রাখি
    }
    // Optional: একটি সুন্দর অর্ডার; না থাকলে ইনপুটের অর্ডারেই থাকবে
    final preferred = [
      'pending',
      'on the way',
      'assignedorder',
      'complete',
      'delivered',
    ];
    final rest = map.keys.where((k) => !preferred.contains(k)).toList();
    _statusTabs = [
      'All',
      ...preferred.where(map.containsKey).map((k) => map[k]!).toList(),
      ...rest.map((k) => map[k]!).toList(),
    ];
  }

  // Entity -> UI
  OrderItem _toOrderItem(DriverOrderEntity e) {
    final inv = e.invoice;
    final orderId = (inv?.taxRef.isNotEmpty == true)
        ? inv!.taxRef
        : (e.tranId.isNotEmpty ? e.tranId : e.id.toString());

    final pickup = inv?.pickupAddress.isNotEmpty == true
        ? inv!.pickupAddress
        : '-';
    final dest = inv?.dropOfAddress.isNotEmpty == true
        ? inv!.dropOfAddress
        : '-';
    final price = e.salePrice != 0 ? e.salePrice : _safeDouble(inv?.payable);

    // 👉 label সরাসরি order.status; রঙের জন্য কেবল classify
    final label = (e.status).toString().trim();
    final kind = _classifyByLabel(label);

    return OrderItem(
      orderId: orderId,
      pickup: pickup,
      destination: dest,
      price: price,
      statusLabel: label, // UI-তে যেটা দেখা যাবে
      kind: kind, // কেবল রঙ ঠিক করতে
    );
  }
}

/* ===== UI-side model ===== */

enum OrderStatus { delivered, pending, onTheWay }

class OrderItem {
  final String orderId;
  final String pickup;
  final String destination;
  final double price;
  final String statusLabel; // ← API-র status ঠিক যেমন আছে
  final OrderStatus kind; // ← শুধু রঙ/স্টাইলের জন্য

  const OrderItem({
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
