import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class DriverDelivered extends StatefulWidget {
  const DriverDelivered({super.key});
  static const routeName = "/driverDelivered";

  @override
  State<DriverDelivered> createState() => _DriverDeliveredState();
}

class _DriverDeliveredState extends State<DriverDelivered> {
  int _tab = 3; // 0=All, 1=Pending, 2=On the way, 3=Delivered (default matches screen)
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchField(controller: _search),
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

            // Cards
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                physics: const BouncingScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _DeliveredCard(
                  orderId: "ORD12345",
                  priceText: r"$7,50",
                  pickupLabel: "Urban tech store",
                  destinationName: "Alex Hossain",
                  onDetails: () => context.go('/driver/delivered/details?id=ORD12345'),
                ),
              ),
            ),

            // bottom grabber
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

/// Search box
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
      onSubmitted: (_) {},
    );
  }
}

/// Filter chips row
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

/// Delivered card
class _DeliveredCard extends StatelessWidget {
  final String orderId;
  final String priceText;
  final String pickupLabel;
  final String destinationName;
  final VoidCallback onDetails;

  const _DeliveredCard({
    required this.orderId,
    required this.priceText,
    required this.pickupLabel,
    required this.destinationName,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
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
          // Top row: status chip + price
          Row(
            children: [
              _StatusPill(text: 'Delivered'),
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

          // Order id
          Text(
            'Order ID $orderId',
            style: TextStyle(color: AllColor.black, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Pickup
          _kvBold('Pick up location: ', pickupLabel),
          const SizedBox(height: 8),

          // Destination
          _kvBold('Destination: ', destinationName),
          const SizedBox(height: 14),

          // See details button
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: onDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColor.loginButtomColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  'See details',
                  style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
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

/// small green-ish status pill
class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    // palette doesn't have a pure green; using green500-ish from your palette family
    final border = AllColor.green500;
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
