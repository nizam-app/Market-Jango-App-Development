// features/driver/screen/driver_order/driver_order.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/driver/screen/driver_order/data/driver_order_data.dart';
import 'package:market_jango/features/driver/screen/driver_order/screen/driver_order_details.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';

class DriverOrder extends ConsumerStatefulWidget {
  const DriverOrder({super.key});
  static const routeName = "/driverOrder";

  @override
  ConsumerState<DriverOrder> createState() => _DriverOrderState();
}

class _DriverOrderState extends ConsumerState<DriverOrder> {
  final _search = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(driverAllOrdersProvider);
    final notifier = ref.read(driverAllOrdersProvider.notifier);
    final tabs = notifier.statusTabs;

    final items = async.hasValue
        ? notifier.toUi(query: _search.text, tabIndex: _tab)
        : const <OrderItem>[];

    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          children: [
            // Optional search
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16.h),
            //   child: _SearchField(
            //     controller: _search,
            //     onChanged: (_) => setState(() {}),
            //   ),
            // ),
            SizedBox(height: 12.h),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: _FilterChipsDynamic(
                  tabs: tabs,
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (_) => ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.w,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => _OrderCard(
                    data: items[i],
                    onSeeDetails: () => context.push(
                      OrderDetailsScreen.routeName,
                      extra: items[i].driverOrderId,
                    ),
                    onTrackOrder: items[i].kind == OrderStatus.delivered
                        ? null
                        : () => context.push(
                            // 👇 এখানেও DriverOrderEntity.id
                            '${DriverTrakingScreen.routeName}?id=${items[i].driverOrderId}',
                          ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),
            // GlobalPagination(
            //   currentPage: notifier.currentPage,
            //   totalPages: notifier.lastPage,
            //   onPageChanged: (p) => notifier.changePage(p),
            // ),
          ],
        ),
      ),
    );
  }
}

/* ===================== Widgets ===================== */

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
        hintText: 'Search by Order ID',
        hintStyle: TextStyle(color: AllColor.textHintColor),
        filled: true,
        fillColor: AllColor.grey100,
        prefixIcon: Icon(Icons.search, color: AllColor.black54),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.w),
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

class _FilterChipsDynamic extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String> tabs;
  const _FilterChipsDynamic({
    required this.selectedIndex,
    required this.onChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = i == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onChanged(i),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AllColor.loginButtomColor
                        : AllColor.grey100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AllColor.loginButtomColor
                          : AllColor.grey200,
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem data;
  final VoidCallback onSeeDetails;
  final VoidCallback? onTrackOrder;

  const _OrderCard({
    required this.data,
    required this.onSeeDetails,
    this.onTrackOrder,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final priceText = "\$${data.price.toStringAsFixed(2).replaceAll('.', ',')}";

    // 🔴 Not Deliver hole action button dekhabo na
    final normStatus = data.statusLabel.toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    final bool hideActions = normStatus.contains('notdeliver');

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
          Row(
            children: [
              _StatusPill(label: data.statusLabel, kind: data.kind),
              const Spacer(),
              Text(
                priceText,
                style: TextStyle(
                  color: AllColor.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 22.sp,
                  letterSpacing: .1,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Order ID ${data.orderId}',
            style: TextStyle(
              color: AllColor.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _kvBold('Pick up location: ', data.pickup),
          SizedBox(height: 8.h),
          _kvBold('Destination: ', data.destination),
          SizedBox(height: 14.h),

          // 🔻 Not Deliver হলে কোন বোতামই দেখাবো না
          if (!hideActions)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PrimaryButton(text: 'See details', onTap: onSeeDetails),
                if (onTrackOrder != null)
                  _SecondaryButton(text: 'Track order', onTap: onTrackOrder!),
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
        style: TextStyle(color: AllColor.black, fontSize: 14.sp),
        children: [
          TextSpan(
            text: v,
            style: TextStyle(
              color: AllColor.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label; // ← ঠিক status টেক্সট
  final OrderStatus kind; // ← রঙ/স্টাইল
  const _StatusPill({required this.label, required this.kind});

  @override
  Widget build(BuildContext context) {
    late Color border;
    switch (kind) {
      case OrderStatus.delivered:
        border = AllColor.green500;
        break;
      case OrderStatus.onTheWay:
        border = AllColor.orange500;
        break;
      case OrderStatus.pending:
        border = AllColor.blue500;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: border.withOpacity(.10),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: border),
      ),
      child: Text(
        label, // ← API-র status যেমন আছে তেমন
        style: TextStyle(
          color: border,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
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
        child: Text(
          text,
          style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700),
        ),
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
      height: 36.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AllColor.blue500, width: 1),
          backgroundColor: AllColor.blue500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 16.h),
        ),
        child: Text(
          text,
          style: TextStyle(color: AllColor.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
