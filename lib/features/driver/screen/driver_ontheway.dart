import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class DriverOntheway extends StatefulWidget {
  const DriverOntheway({super.key});
  static const routeName = "/on-the-way";

  @override
  State<DriverOntheway> createState() => _DriverOnthewayState();
}

class _DriverOnthewayState extends State<DriverOntheway> {
  final _search = TextEditingController();
  int _tab = 2; // 0=All, 1=Pending, 2=On the way, 3=Delivered (default: On the way)

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _demoOrders
        .where((e) {
          if (_tab == 0) return true;
          if (_tab == 1) return e.status == DriverOrderStatus.pending;
          if (_tab == 2) return e.status == DriverOrderStatus.onTheWay;
          return e.status == DriverOrderStatus.delivered;
        })
        .where((e) =>
            _search.text.trim().isEmpty ||
            e.orderId.toLowerCase().contains(_search.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AllColor.white,
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AllColor.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchField(
                controller: _search,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FilterChips(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 12),

            // Cards list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _OrderCard(
                  data: items[i],
                  onSeeDetails: () => context.go('/driver/order/details?id=${items[i].orderId}'),
                  onTrackOrder: () => context.go('/driver/order/track?id=${items[i].orderId}'),
                ),
              ),
            ),

            // iOS home-indicator style grabber
            Container(
              color: AllColor.white,
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Center(
                child: Container(
                  height: 5,
                  width: 110,
                  decoration: BoxDecoration(
                    color: AllColor.grey200,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- Models & Demo Data -------------------- */

enum DriverOrderStatus { delivered, pending, onTheWay }

class OrderItem {
  final String orderId;
  final String pickup;
  final String destination;
  final double price;
  final DriverOrderStatus status;

  const OrderItem({
    required this.orderId,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.status,
  });
}

const _demoOrders = <OrderItem>[
  OrderItem(
    orderId: 'ORD12345',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: DriverOrderStatus.onTheWay,
  ),
  OrderItem(
    orderId: 'ORD12346',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: DriverOrderStatus.onTheWay,
  ),
  OrderItem(
    orderId: 'ORD12347',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: DriverOrderStatus.onTheWay,
  ),
  // extra items for other tabs
  OrderItem(
    orderId: 'ORD12348',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: DriverOrderStatus.pending,
  ),
  OrderItem(
    orderId: 'ORD12349',
    pickup: 'Urban tech store',
    destination: 'Alex Hossain',
    price: 7.50,
    status: DriverOrderStatus.delivered,
  ),
];

/* -------------------- Reusable Widgets -------------------- */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search order',
        hintStyle: TextStyle(color: AllColor.textHintColor),
        filled: true,
        fillColor: AllColor.grey100,
        prefixIcon: Icon(Icons.search, color: AllColor.black54),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AllColor.blue500),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _FilterChips({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Pending', 'On the way', 'Delivered'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final selected = i == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AllColor.loginButtomColor : AllColor.grey100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AllColor.loginButtomColor : AllColor.grey200,
                ),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: selected ? AllColor.white : AllColor.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem data;
  final VoidCallback onSeeDetails;
  final VoidCallback onTrackOrder;

  const _OrderCard({
    required this.data,
    required this.onSeeDetails,
    required this.onTrackOrder,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = "\$${data.price.toStringAsFixed(2).replaceAll('.', ',')}";

    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AllColor.grey200),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // status + price
          Row(
            children: [
              _StatusPill(status: data.status),
              const Spacer(),
              Text(
                priceText,
                style: TextStyle(
                  color: AllColor.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: .1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Order ID ${data.orderId}',
              style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          _kvBold('Pick up location: ', data.pickup),
          const SizedBox(height: 8),
          _kvBold('Destination: ', data.destination),
          const SizedBox(height: 14),

          // buttons
          Row(
            children: [
              _PrimaryButton(text: 'See details', onTap: onSeeDetails),
              const SizedBox(width: 10),
              _SecondaryButton(text: 'Track order', onTap: onTrackOrder),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvBold(String k, String v) {
    return RichText(
      text: TextSpan(
        text: k,
        style: TextStyle(color: AllColor.black, fontSize: 14),
        children: [
          TextSpan(
            text: v,
            style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DriverOrderStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color border;
    late String text;
    switch (status) {
      case DriverOrderStatus.delivered:
        border = AllColor.green500;
        text = 'Delivered';
        break;
      case DriverOrderStatus.pending:
        border = AllColor.blue500;
        text = 'Pending';
        break;
      case DriverOrderStatus.onTheWay:
        border = AllColor.orange500;
        text = 'On the way';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: border.withOpacity(.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(color: border, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AllColor.loginButtomColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(text,
            style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AllColor.blue500, width: 1),
          backgroundColor: AllColor.blue500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(text,
            style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}