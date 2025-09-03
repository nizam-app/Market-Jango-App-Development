import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class VendorProductColor extends StatefulWidget {
  const VendorProductColor({super.key});
  static const routeName = '/vendorProductColor';

  @override
  State<VendorProductColor> createState() => _VendorProductColorState();
}

class _VendorProductColorState extends State<VendorProductColor> {
  final List<Map<String, dynamic>> colors = [
    {"hex": "FFFFFF", "selected": false},
    {"hex": "653518", "selected": false},
    {"hex": "558612", "selected": false},
    {"hex": "267400", "selected": false},
    {"hex": "449003", "selected": false},
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
       appBar: AppBar(title: Text('Color attribute', style: TextStyle(color: AllColor.black))),
      body: Padding(
        padding:  EdgeInsets.all(16.h),
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
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(3),
              },
              children: [
                /// Header Row
                 TableRow(
                  decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0.h),
                      child: Text(
                        "Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.h),
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
                    children: [
                      /// Color Box
                      InkWell(
                        onTap: () => _pickColor(index),
                        child: Container(
                          height: 40.h,
                          alignment: Alignment.center,
                          child: Container(
                            width: 40.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse("0xFF${colors[index]['hex']}"),
                              ),
                              border: Border.all(color: Colors.black26),
                            ),
                          ),
                        ),
                      ),

                      /// Checkbox + Hex value
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 8.h),
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
