import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// change import to your real path
import 'package:market_jango/core/constants/color_control/all_color.dart';

/// ------- MODEL -------
class SizeRow {
  String name;
  String value; // e.g. XS, S, M, L, XL, 2XL ...
  SizeRow(this.name, this.value);
}

/// ------- SCREEN -------
class MyProductSizeScreen extends StatelessWidget {
  MyProductSizeScreen({super.key});
  static const routeName = '/myProductSizeScreen';

  final items = <SizeRow>[
    SizeRow('Angel', 'S'),
    SizeRow('Shane', 'M'),
    SizeRow('Courtney', 'L'),
    SizeRow('Mitchell', 'XL'),
    SizeRow('Cody', 'XXL'),
  ];

  // Shop presets (you can change)
  final presetSizes = const <String>[
    'XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Size attribute', style: TextStyle(color: AllColor.black))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SizeAttributeTable(
            items: items,
            presetSizes: presetSizes,
            onChanged: (rows) {
              // Updated list arrives here
            },
          ),
        ),
      ),
    );
  }
}

/// ------- TABLE -------
class SizeAttributeTable extends StatefulWidget {
  const SizeAttributeTable({
    super.key,
    required this.items,
    this.presetSizes = const ['XS','S','M','L','XL','XXL'],
    this.onChanged,
    this.title = '',
    this.label = 'Size',
  });

  final List<SizeRow> items;
  final List<String> presetSizes;
  final ValueChanged<List<SizeRow>>? onChanged;
  final String title;
  final String label;

  @override
  State<SizeAttributeTable> createState() => _SizeAttributeTableState();
}

class _SizeAttributeTableState extends State<SizeAttributeTable> {
  late List<SizeRow> _items = List<SizeRow>.from(widget.items);

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
        if (widget.title.isNotEmpty) SizedBox(height: 8.h),
        Text(widget.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AllColor.black.withOpacity(0.7),
              fontSize: 12.sp,
            )),
        SizedBox(height: 10.h),

        // Actions
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _addRow,
              icon: Icon(Icons.add, size: 16.sp, color: AllColor.black),
              label: Text('Add size', style: TextStyle(color: AllColor.black, fontSize: 13.sp)),
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
            border: TableBorder.symmetric(inside: BorderSide(color: borderColor, width: 1)),
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
        // Editable name — borderless like your Color screen
        _Cell(
          pad: 12.w,
          child: TextFormField(
            key: ValueKey('name_${i}_${item.name.hashCode}'),
            initialValue: item.name,
            style: TextStyle(color: AllColor.black, fontSize: 14.sp),
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => _updateRow(i, item..name = v),
          ),
        ),

        // Value (tap -> picker dialog with size chips)
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
                  // small square to mimic the color box place; here just a grey chip
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: AllColor.grey.withOpacity(0.15),
                      border: Border.all(color: AllColor.grey.withOpacity(0.6), width: 1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.value.length > 2 ? item.value.substring(0, 2) : item.value,
                      style: TextStyle(fontSize: 9.sp, color: AllColor.black),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    item.value,
                    style: TextStyle(letterSpacing: 0.5, color: AllColor.black, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Delete
        _Cell(
          pad: 6.w,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Remove',
              splashRadius: 20.r,
              onPressed: () => _removeRow(i),
              icon: Icon(Icons.delete_outline, size: 20.sp, color: AllColor.grey.withOpacity(0.9)),
            ),
          ),
        ),
      ],
    );
  }

  // Actions
  void _addRow() {
    setState(() => _items.add(SizeRow('New size', 'S')));
    widget.onChanged?.call(_items);
  }

  void _removeRow(int index) {
    setState(() => _items.removeAt(index));
    widget.onChanged?.call(_items);
  }

  void _updateRow(int i, SizeRow row) {
    setState(() => _items[i] = row);
    widget.onChanged?.call(_items);
  }

  Future<void> _openPicker(int index) async {
    String current = _items[index].value;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AllColor.white,
        contentPadding: EdgeInsets.all(12.w),
        title: Text('Select size',
            style: TextStyle(color: AllColor.black, fontSize: 16.sp, fontWeight: FontWeight.w700)),
        content: StatefulBuilder(
          builder: (_, setSB) => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.presetSizes.map((s) {
              final selected = s == current;
              return ChoiceChip(
                label: Text(s, style: TextStyle(color: AllColor.black)),
                selected: selected,
                selectedColor: AllColor.grey.withOpacity(0.15),
                shape: StadiumBorder(
                  side: BorderSide(color: selected ? AllColor.black : AllColor.grey.withOpacity(0.35)),
                ),
                onSelected: (_) {
                  setSB(() => current = s);
                  _updateRow(index, _items[index]..value = s); // realtime update
                },
              );
            }).toList(),
          ),
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
        title: Text('Select sizes',
            style: TextStyle(color: AllColor.black, fontSize: 16.sp, fontWeight: FontWeight.w700)),
        content: StatefulBuilder(
          builder: (_, setSB) => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(widget.presetSizes.length, (i) {
              final s = widget.presetSizes[i];
              final isSel = selected.contains(i);
              return FilterChip(
                selected: isSel,
                onSelected: (v) => setSB(() => v ? selected.add(i) : selected.remove(i)),
                label: Text(s, style: TextStyle(color: AllColor.black)),
                selectedColor: AllColor.grey.withOpacity(0.15),
                backgroundColor: AllColor.white,
                shape: StadiumBorder(side: BorderSide(color: AllColor.grey.withOpacity(0.3))),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AllColor.black, fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              final toAdd = selected.map((i) => widget.presetSizes[i]).toList();
              setState(() {
                for (final s in toAdd) {
                  final exists = _items.any((r) =>
                  r.name.toLowerCase() == s.toLowerCase() && r.value.toLowerCase() == s.toLowerCase());
                  if (!exists) _items.add(SizeRow(s, s));
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
}

class _Cell extends StatelessWidget {
  const _Cell({required this.child, this.pad = 12});
  final Widget child;
  final double pad;

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(pad), child: child);
}