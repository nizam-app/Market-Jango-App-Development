import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'logic/prement_reverpod.dart';

class BuyerPaymentScreen extends ConsumerWidget {
  const BuyerPaymentScreen({super.key});
  static const routeName = "/buyerPaymentScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(productFutureProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error: $e")),
          data: (data) {
            // init defaults once
            final ship = ref.read(selectedShippingProvider);
            final pay  = ref.read(selectedPaymentProvider);
            if (ship.isEmpty) {
              ref.read(selectedShippingProvider.notifier).state = data.selectedShippingId;
            }
            if (pay.isEmpty || pay == 'card') {
              ref.read(selectedPaymentProvider.notifier).state = data.selectedPaymentMethod;
            }

            final shippingId = ref.watch(selectedShippingProvider);
            final payment = ref.watch(selectedPaymentProvider);

            return BuyerPaymentView(
              onBack: () => Navigator.pop(context),
              shippingAddressLines: data.shippingAddress,
              onEditAddress: () {},
              contactLines: data.contact,
              onEditContact: () {},
              items: data.items
                  .map((e) => CartItemVM(title: e.title, price: e.price, image: AssetImage(e.image)))
                  .toList(),
              shippingOptions: data.shippingOptions
                  .map((e) => ShippingOptionVM(id: e.id, label: e.label, price: e.price))
                  .toList(),
              selectedShippingId: shippingId,
              onShippingChanged: (id) => ref.read(selectedShippingProvider.notifier).state = id,
              paymentMethod: _toEnum(payment),
              onPaymentChanged: (m) => ref.read(selectedPaymentProvider.notifier).state = _fromEnum(m),
            );
          },
        ),
      ),
    );
  }

  // map string <-> enum for BuyerPaymentView
  PaymentMethod _toEnum(String v) {
    switch (v) {
      case 'gpay': return PaymentMethod.gpay;
      case 'paypal': return PaymentMethod.paypal;
      case 'cod': return PaymentMethod.cod;
      default: return PaymentMethod.card;
    }
  }

  String _fromEnum(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.gpay: return 'gpay';
      case PaymentMethod.paypal: return 'paypal';
      case PaymentMethod.cod: return 'cod';
      case PaymentMethod.card: default: return 'card';
    }
  }
}



enum PaymentMethod { card, gpay, paypal, cod }

class ShippingOptionVM {
  final String id;
  final String label;
  final double price;
  const ShippingOptionVM({required this.id, required this.label, required this.price});
}

class CartItemVM {
  final String title;
  final double price;
  final ImageProvider image;
  const CartItemVM({required this.title, required this.price, required this.image});
}

class BuyerPaymentView extends StatelessWidget {
  const BuyerPaymentView({
    super.key,
    required this.onBack,
    this.title = 'Payment',
    required this.shippingAddressLines,
    required this.onEditAddress,
    required this.contactLines,
    required this.onEditContact,
    required this.items,
    required this.shippingOptions,
    required this.selectedShippingId,
    required this.onShippingChanged,
    required this.paymentMethod,
    required this.onPaymentChanged,
  });

  // header
  final VoidCallback onBack;
  final String title;

  // address / contact
  final List<String> shippingAddressLines;
  final VoidCallback onEditAddress;
  final List<String> contactLines;
  final VoidCallback onEditContact;

  // items
  final List<CartItemVM> items;

  // shipping
  final List<ShippingOptionVM> shippingOptions;
  final String selectedShippingId;
  final ValueChanged<String> onShippingChanged;

  // payment
  final PaymentMethod paymentMethod;
  final ValueChanged<PaymentMethod> onPaymentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(title: title, onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _InfoCard(title: "Shipping Address", lines: shippingAddressLines, onEdit: onEditAddress),
                  _InfoCard(title: "Contact Information", lines: contactLines, onEdit: onEditContact),

                  _SectionHeader(title: "Items", pill: items.length.toString()),
                  ...items.map((e) => _ItemTile(title: e.title, price: e.price, image: e.image)),

                  _SectionHeader(title: "Shipping Options"),
                  ...shippingOptions.map((o) => _ShippingTile(
                    selected: selectedShippingId == o.id,
                    label: o.label,
                    price: o.price,
                    onTap: () => onShippingChanged(o.id),
                  )),

                  _SectionHeader(title: "Payment Method"),
                  _PayChips(value: paymentMethod, onChanged: onPaymentChanged),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------- Private UI ---------- */

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 8.h),
        child: Row(
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                child: Icon(Icons.arrow_back, size: 18.r),
              ),
            ),
            SizedBox(width: 10.w),
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines, required this.onEdit});
  final String title;
  final List<String> lines;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: _box(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Text(lines.join("\n"), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563))),
            ]),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
              child: Icon(Icons.edit, size: 16.r, color: const Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.pill});
  final String title;
  final String? pill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
          if (pill != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(999)),
              child: Text(pill!, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.title, required this.price, required this.image});
  final String title;
  final double price;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          CircleAvatar(radius: 18.r, backgroundImage: image),
          SizedBox(width: 10.w),
          Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
          Text("\$${price.toStringAsFixed(0)}", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ShippingTile extends StatelessWidget {
  const _ShippingTile({required this.selected, required this.label, required this.price, this.onTap});
  final bool selected; final String label; final double price; final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFD1E5FF) : const Color(0xFFF3F4F6);
    final border = selected ? const Color(0xFF93C5FD) : const Color(0xFFF3F4F6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: border)),
        child: Row(
          children: [
            _RadioDot(checked: selected),
            SizedBox(width: 10.w),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
            Text(price == 0 ? "Free" : "\$${price.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.r, height: 20.r,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: checked ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF), width: 2)),
      child: Center(child: Container(width: 10.r, height: 10.r, decoration: BoxDecoration(color: checked ? const Color(0xFF2563EB) : Colors.transparent, shape: BoxShape.circle))),
    );
  }
}

class _PayChips extends StatelessWidget {
  const _PayChips({required this.value, required this.onChanged});
  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(PaymentMethod id, String label, IconData icon) {
      final selected = value == id;
      return InkWell(
        onTap: () => onChanged(id),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF1CC) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: selected ? const Color(0xFFFFA000) : const Color(0xFFE5E7EB)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18.r, color: const Color(0xFF111827)),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
          ]),
        ),
      );
    }

    return Wrap(
      spacing: 10.w, runSpacing: 10.h,
      children: [
        chip(PaymentMethod.card, 'Card', Icons.credit_card),
        chip(PaymentMethod.gpay, 'G Pay', Icons.account_balance_wallet_outlined),
        chip(PaymentMethod.paypal, 'PayPal', Icons.paypal),
        chip(PaymentMethod.cod, 'COD', Icons.receipt_long),
      ],
    );
  }
}

BoxDecoration _box() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 4.h))],
);