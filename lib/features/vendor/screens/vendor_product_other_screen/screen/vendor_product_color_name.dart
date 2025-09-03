import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class VendorProductColorName extends StatefulWidget {
  const VendorProductColorName({super.key});
  static const routeName = '/vendorProductColorName';

  @override
  State<VendorProductColorName> createState() => _VendorProductColorNameState();
}

class _VendorProductColorNameState extends State<VendorProductColorName> {
  final List<Map<String, dynamic>> colors = [
    {"name": "Angel", "hex": "FFFFFF", "selected": false},
    {"name": "Shane", "hex": "653518", "selected": false},
    {"name": "Courtney", "hex": "558612", "selected": false},
    {"name": "Mitchell", "hex": "267400", "selected": false},
    {"name": "Cody", "hex": "449003", "selected": false},
  ];

  void _pickColor(int index) {
    Color currentColor = Color(int.parse("0xFF${colors[index]['hex']}"));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  colors[index]['hex'] =
                      color.value.toRadixString(16).substring(2).toUpperCase();
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(title: Text('Color Name Attribute', style: TextStyle(color: AllColor.black))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Color",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 12.h),

            /// Table widget
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2), // Name
                1: FlexColumnWidth(3), // Value
              },
              children: [
                /// Header Row
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Value",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                /// Data Rows
                ...List.generate(colors.length, (index) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? Colors.grey.shade200
                          : Colors.white,
                    ),
                    children: [
                      /// Name Column
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(colors[index]['name']),
                      ),

                      /// Checkbox + Hex value
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: colors[index]['selected'],
                              onChanged: (val) {
                                setState(() {
                                  colors[index]['selected'] = val ?? false;
                                });
                              },
                            ),
                            InkWell(
                              onTap: () => _pickColor(index),
                              child: Container(
                                width: 40,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse("0xFF${colors[index]['hex']}"),
                                  ),
                                  border: Border.all(color: Colors.black26),
                                ),
                              ),
                            ),
                            Text(colors[index]['hex']),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
