import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomVariantPicker extends ConsumerStatefulWidget {
  const CustomVariantPicker({
    super.key,
    this.colors = const [],
    this.sizes = const ['S', 'M', 'L', 'XL', 'XXL'],
    this.onColorsChanged,
    this.onSizesChanged,
    this.selectedColors = const [],
    this.selectedSizes = const [],
  });

  final List<String> colors;
  final List<String> sizes;
  final ValueChanged<List<String>>? onColorsChanged;
  final ValueChanged<List<String>>? onSizesChanged;
  final List<String> selectedColors;
  final List<String> selectedSizes;

  @override
  ConsumerState<CustomVariantPicker> createState() => _CustomVariantPickerState();
}

class _CustomVariantPickerState extends ConsumerState<CustomVariantPicker> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          /// ==== LEFT: COLOR PICKER ====
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
                    final isSelected = widget.selectedColors.contains(color);

                    return GestureDetector(
                      onTap: () {
                        /// ❗ Always copy before modifying (immutable fix)
                        final updatedColors =
                        List<String>.from(widget.selectedColors);

                        if (isSelected) {
                          updatedColors.remove(color);
                        } else {
                          updatedColors.add(color);
                        }

                        widget.onColorsChanged?.call(updatedColors);
                      },
                      child:
                      _ColorDot(color: "0xff$color", selected: isSelected),
                    );
                  }),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          /// ==== RIGHT: SIZE PICKER ====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(label: 'Select Size'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 10.h,
                  children: widget.sizes.map((size) {
                    final selected = widget.selectedSizes.contains(size);
                    return GestureDetector(
                      onTap: () {
                        /// ❗ Copy list before modifying
                        final updatedSizes =
                        List<String>.from(widget.selectedSizes);

                        if (selected) {
                          updatedSizes.remove(size);
                        } else {
                          updatedSizes.add(size);
                        }

                        widget.onSizesChanged?.call(updatedSizes);
                      },
                      child: _SizeChip(label: size, selected: selected),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header box
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
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF444444),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Color circle
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, this.selected = false});
  final String color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(int.parse(color)),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xffE6E6E6),
            width: selected ? 3.w : 1.w,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ]
              : [],
        ),
      ),
    );
  }
}

/// Size Chip
class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A7CFF) : const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: selected
              ? [
            BoxShadow(
              color: const Color(0xFF4A7CFF).withOpacity(0.35),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF4A7CFF),
          ),
        ),
      ),
    );
  }
}