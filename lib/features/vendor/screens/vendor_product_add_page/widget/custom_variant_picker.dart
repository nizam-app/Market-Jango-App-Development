import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomVariantPicker extends StatefulWidget {
  const CustomVariantPicker({
    super.key,
    this.colors = const [
      Color(0xFFE53935),
      Color(0xFF40C4FF),
      Color(0xFF76FF03),
      Color(0xFF7C4DFF),
      Color(0xFFEF9A9A),
      Color(0xFF9E9D24),
      Color(0xFF7CB342),
      Color(0xFFB0BEC5),
    ],
    this.sizes = const ['S', 'M', 'L', 'XL', 'XXL'],
    this.onColorsChanged,
    this.onSizesChanged,
  });

  final List<Color> colors;
  final List<String> sizes;
  final ValueChanged<List<Color>>? onColorsChanged;
  final ValueChanged<List<String>>? onSizesChanged;

  @override
  State<CustomVariantPicker> createState() => _CustomVariantPickerState();
}

class _CustomVariantPickerState extends State<CustomVariantPicker> {
  final List<Color> _selectedColors = [];
  final List<String> _selectedSizes = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ===== Left: Color =====
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(label: 'Select Color'),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: List.generate(widget.colors.length, (i) {
                  final color = widget.colors[i];
                  final isSelected = _selectedColors.contains(color);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedColors.remove(color);
                        } else {
                          _selectedColors.add(color);
                        }
                      });
                      widget.onColorsChanged?.call(_selectedColors);
                    },
                    child: _ColorDot(color: color, selected: isSelected),
                  );
                }),
              ),
            ],
          ),
        ),

        SizedBox(width: 14.w),

        // ===== Right: Size =====
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(label: 'Select Size'),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: widget.sizes.map((size) {
                  final selected = _selectedSizes.contains(size);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedSizes.remove(size);
                        } else {
                          _selectedSizes.add(size);
                        }
                      });
                      widget.onSizesChanged?.call(_selectedSizes);
                    },
                    child: _SizeChip(label: size, selected: selected),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Top rounded card with chevron (visual only, like the mock)
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF444444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Icon(
          //   Icons.keyboard_arrow_down_rounded,
          //   size: 22.sp,
          //   color: const Color(0xFF7A7A7A),
          // ),
        ],
      ),
    );
  }
}

/// Round color swatch with black ring (thicker when selected)
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, this.selected = false});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.black, width: selected ? 4.w : 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
    );
  }
}

/// Light pill chip for sizes (blue-tinted like the mock)
class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFD9E9FF) : const Color(0xFFEFF5FD);
    final fg = selected ? const Color(0xFF2E6CE6) : const Color(0xFF7A8EAD);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
