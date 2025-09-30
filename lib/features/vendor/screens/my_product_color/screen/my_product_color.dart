import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 👉 তোমার প্রকল্প অনুযায়ী path ঠিক করো
import 'package:market_jango/core/constants/color_control/all_color.dart';

import '../model/color_model.dart';

/// ===== Screen =====
class MyProductColorScreen extends StatelessWidget {
  MyProductColorScreen({super.key});
  static const routeName = "/myProductColorScreen";

  // শুরুতে কিছু ডেমো ডাটা
  final items = <ColorRow>[
    ColorRow('Angel', const Color(0xFFFFFFFF)),
    ColorRow('Shane', const Color(0xFF653518)),
    ColorRow('Courtney', const Color(0xFF558612)),
    ColorRow('Mitchell', const Color(0xFF267400)),
    ColorRow('Cody', const Color(0xFF449003)),
  ];

  // দোকানের প্রিসেট কালার (চাইলেই বাইরে থেকে পাঠাতে পারো)
  final availablePresets = const <MapEntry<String, Color>>[
    MapEntry('White', Color(0xFFFFFFFF)),
    MapEntry('Black', Color(0xFF000000)),
    MapEntry('Red', Color(0xFFFF3B30)),
    MapEntry('Green', Color(0xFF34C759)),
    MapEntry('Blue', Color(0xFF007AFF)),
    MapEntry('Yellow', Color(0xFFFFCC00)),
    MapEntry('Orange', Color(0xFFFF9500)),
    MapEntry('Brown', Color(0xFF8E5A3C)),
    MapEntry('Gray', Color(0xFF8E8E93)),
    MapEntry('Purple', Color(0xFFAF52DE)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Color attribute', style: TextStyle(color: AllColor.black))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ColorAttributeTable(
            items: items,
            availablePresets: availablePresets,
            onChanged: (rows) {
              // rows = আপডেটেড লিস্ট (name + color)
            },
          ),
        ),
      ),
    );
  }
}

/// ===== Table + actions (edit name, pick color, add/remove, add from presets) =====
class ColorAttributeTable extends StatefulWidget {
  const ColorAttributeTable({
    super.key,
    required this.items,
    this.availablePresets,
    this.onChanged,
    this.title = '',
    this.label = 'Color',
  });

  final List<ColorRow> items;
  final List<MapEntry<String, Color>>? availablePresets;
  final ValueChanged<List<ColorRow>>? onChanged;
  final String title;
  final String label;

  @override
  State<ColorAttributeTable> createState() => _ColorAttributeTableState();
}

class _ColorAttributeTableState extends State<ColorAttributeTable> {
  late List<ColorRow> _items = List<ColorRow>.from(widget.items);

  late final List<MapEntry<String, Color>> _presets =
      widget.availablePresets ??
          const [
            MapEntry('White', Color(0xFFFFFFFF)),
            MapEntry('Black', Color(0xFF000000)),
            MapEntry('Red', Color(0xFFFF3B30)),
            MapEntry('Green', Color(0xFF34C759)),
            MapEntry('Blue', Color(0xFF007AFF)),
            MapEntry('Yellow', Color(0xFFFFCC00)),
            MapEntry('Orange', Color(0xFFFF9500)),
            MapEntry('Brown', Color(0xFF8E5A3C)),
            MapEntry('Gray', Color(0xFF8E8E93)),
            MapEntry('Purple', Color(0xFFAF52DE)),
          ];

  @override
  Widget build(BuildContext context) {
    final borderColor = AllColor.grey.withOpacity(0.25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Text(widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AllColor.black,
                fontSize: 16.sp,
              )),
        SizedBox(height: 8.h),
        Text(widget.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AllColor.black.withOpacity(0.7),
              fontSize: 12.sp,
            )),
        SizedBox(height: 10.h),

        // Action row
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _addBlankRow,
              icon: Icon(Icons.add, size: 16.sp, color: AllColor.black),
              label: Text('Add color', style: TextStyle(color: AllColor.black, fontSize: 13.sp)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
            ),
            SizedBox(width: 10.w),
            TextButton(
              onPressed: _showAddFromPresets,
              child: Text('Add from presets', style: TextStyle(fontSize: 13.sp, color: AllColor.black)),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(6.r),
            color: AllColor.white,
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), // Name
              1: FlexColumnWidth(1),   // Value
              2: FlexColumnWidth(0.4), // Actions
            },
            border: TableBorder.symmetric(
              inside: BorderSide(color: borderColor, width: 1),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              _headerRow(),
              for (int i = 0; i < _items.length; i++) _dataRow(i),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _headerRow() => TableRow(
    decoration: BoxDecoration(color: AllColor.grey.withOpacity(0.08)),
    children: [
      _Cell(
        pad: 12.w,
        child: Text('Name',
            style: TextStyle(fontWeight: FontWeight.w600, color: AllColor.black, fontSize: 14.sp)),
      ),
      _Cell(
        pad: 12.w,
        child: Text('Value',
            style: TextStyle(fontWeight: FontWeight.w600, color: AllColor.black, fontSize: 14.sp)),
      ),
      const _Cell(pad: 12, child: SizedBox.shrink()),
    ],
  );

  TableRow _dataRow(int i) {
    final item = _items[i];
    return TableRow(
      children: [
        // Editable name
        _Cell(
          pad: 12.w,
          child: TextFormField(
            key: ValueKey('name_${i}_${item.name.hashCode}'),
            initialValue: item.name,
            style: TextStyle(color: AllColor.black, fontSize: 14.sp),
            decoration: const InputDecoration(
              isDense: true,
              filled: false,                    // <- কোনো ব্যাকগ্রাউন্ড ফিল নয়
              border: InputBorder.none,         // <- সব বর্ডার অফ
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,  // <- সেলের ভেতরেই থাকবে
            ),
            onChanged: (v) => _updateRow(i, item..name = v),
          ),
        ),

        // Color value (tap to pick)
        _Cell(
          pad: 8.w,
          child: InkWell(
            onTap: () => _openPicker(i),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AllColor.white,
                border: Border.all(color: AllColor.grey.withOpacity(0.28), width: 1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: item.color,
                      border: Border.all(color: AllColor.grey.withOpacity(0.6), width: 1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _hex(item.color),
                    style: TextStyle(letterSpacing: 0.5, color: AllColor.black, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Delete action
        _Cell(
          pad: 6.w,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Remove',
              onPressed: () => _removeRow(i),
              icon: Icon(Icons.delete_outline, size: 20.sp, color: AllColor.grey.withOpacity(0.9)),
              splashRadius: 20.r,
            ),
          ),
        ),
      ],
    );
  }

  // ===== Actions =====
  void _addBlankRow() {
    setState(() => _items.add(ColorRow('New color', const Color(0xFFFFFFFF))));
    widget.onChanged?.call(_items);
  }

  void _removeRow(int index) {
    setState(() => _items.removeAt(index));
    widget.onChanged?.call(_items);
  }

  void _updateRow(int i, ColorRow row) {
    setState(() => _items[i] = row);
    widget.onChanged?.call(_items);
  }

  Future<void> _openPicker(int index) async {
    Color current = _items[index].color;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        contentPadding: EdgeInsets.all(12.w),
        content: StatefulBuilder(
          builder: (_, setSB) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HSV Picker (live)
                  ColorPicker(
                    pickerColor: current,
                    onColorChanged: (c) {
                      setSB(() => current = c);
                      _updateRow(index, _items[index]..color = c); // live update
                    },
                    enableAlpha: false, // 6-digit HEX রাখতে
                    displayThumbColor: true,
                  ),
                  SizedBox(height: 8.h),
              
                  // Preset block picker
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Presets',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: AllColor.black, fontSize: 13.sp)),
                  ),
                  SizedBox(height: 8.h),
                  BlockPicker(
                    pickerColor: current,
                    availableColors: _presets.map((e) => e.value).toList(),
                    onColorChanged: (c) {
                      _updateRow(index, _items[index]..color = c);
                      setSB(() => current = c);
                    },
                  ),
              
                  SizedBox(height: 6.h),
                  Text('HEX: ${_hex(current)}',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AllColor.black, fontSize: 14.sp)),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: AllColor.black, fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFromPresets() async {
    final selected = <int>{};

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        title: Text('Select presets',
            style: TextStyle(color: AllColor.black, fontSize: 16.sp, fontWeight: FontWeight.w700)),
        content: StatefulBuilder(
          builder: (_, setSB) => SingleChildScrollView(
            child: Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: List.generate(_presets.length, (i) {
                final entry = _presets[i];
                final isSel = selected.contains(i);
                return FilterChip(
                  selected: isSel,
                  onSelected: (v) => setSB(() {
                    v ? selected.add(i) : selected.remove(i);
                  }),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: entry.value,
                          borderRadius: BorderRadius.circular(3.r),
                          border: Border.all(color: AllColor.grey.withOpacity(0.5)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(entry.key, style: TextStyle(color: AllColor.black, fontSize: 12.sp)),
                    ],
                  ),
                  selectedColor: AllColor.grey.withOpacity(0.15),
                  backgroundColor: AllColor.white,
                  shape: StadiumBorder(side: BorderSide(color: AllColor.grey.withOpacity(0.3))),
                );
              }),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AllColor.black, fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              final toAdd = selected.map((i) => _presets[i]).toList();
              setState(() {
                for (final e in toAdd) {
                  final exists = _items.any((r) => r.name.toLowerCase() == e.key.toLowerCase());
                  if (!exists) _items.add(ColorRow(e.key, e.value));
                }
              });
              widget.onChanged?.call(_items);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.black,
              foregroundColor: AllColor.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
            ),
            child: Text('Add', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _hex(Color c) => c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
}

class _Cell extends StatelessWidget {
  const _Cell({required this.child, this.pad = 12});
  final Widget child;
  final double pad;

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(pad), child: child);
}