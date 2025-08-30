import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/features/buyer/screens/prement/model/prement_model.dart';

class CustomPaymentMethod extends StatefulWidget {
  const CustomPaymentMethod({
    super.key,
    required this.options,
    this.initialIndex = 0,
    this.onChanged,
  });

  final List<PaymentOption> options;
  final int initialIndex;
  final ValueChanged<int>? onChanged;  

  @override
  State<CustomPaymentMethod> createState() => _CustomPaymothodMethodState();
}

class _CustomPaymothodMethodState extends State<CustomPaymentMethod> {
  late int _selected;

  @override
  void initState() {
    _selected = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        SizedBox(
          height: 40.h, // fixed height so chips don’t expand
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.options.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, i) {
              final selected = _selected == i;
              final opt = widget.options[i];

              return _PaymentChip(
                label: opt.label,
                icon: opt.icon,
                asset: opt.asset,
                selected: selected,
                onTap: () {
                  setState(() => _selected = i);
                  widget.onChanged?.call(i);
                },
              );
            },
          ),
        ),
        SizedBox(height: 10.h,)
      ],
    )
    ;
  }
}

/// ====================== CHIP ======================
class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    this.icon,
    this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.r),
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal:
        10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? Colors.orange : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // show Icon if available, otherwise asset image
            if (icon != null)
              Icon(icon, size: 15.sp, color: Colors.black)
            else if (asset != null)
              Image.asset(asset!, width: 15.w, height: 15.w, fit: BoxFit.contain)
            else
              Icon(Icons.payment, size: 15.sp, color: Colors.black54),

            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}