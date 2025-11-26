// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:market_jango/core/constants/color_control/all_color.dart';
// import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';
//
// class VendorPendingScreen extends StatefulWidget {
//   const VendorPendingScreen({super.key});
//   static const routeName = "/vendorPendingScreen";
//
//   @override
//   State<VendorPendingScreen> createState() =>
//       _VendorPendingScreenState();
// }
//
// class _VendorPendingScreenState
//     extends State<VendorPendingScreen> {
//   // 0 = Request transport, 1 = Track shipments (default)
//   int _segment = 1;
//
//   // 0 = Pending (default), 1 = Completed, 2 = Cancelled
//   int _tab = 0;
//
//   final _search = TextEditingController();
//   int? _selectedIndex; // blue outlined card
//
//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final items = _demoOrders
//         .where((e) =>
//             _search.text.trim().isEmpty ||
//             e.title.toLowerCase().contains(_search.text.toLowerCase()) ||
//             e.customer.toLowerCase().contains(_search.text.toLowerCase()))
//         .toList();
//
//     return Scaffold(
//       backgroundColor: AllColor.white,
//
//       body: SafeArea(
//         child: Padding(
//          padding:  EdgeInsets.symmetric(horizontal: 16.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               CustomBackButton(),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _SegmentedToggle(
//                   leftText: 'Request transport',
//                   rightText: 'Track shipments',
//                   value: _segment,
//                   onChanged: (v) {
//                     setState(() => _segment = v);
//                     // if (v == 0) context.go('/vendor/transporter');
//                   },
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // Search
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextField(
//                   controller: _search,
//                   onChanged: (_) => setState(() {}),
//                   textInputAction: TextInputAction.search,
//                   decoration: InputDecoration(
//                     hintText: 'Search you product',
//                     hintStyle: TextStyle(color: AllColor.textHintColor),
//                     prefixIcon:
//                         Icon(Icons.search_rounded, color: AllColor.black54),
//                     filled: true,
//                     fillColor: AllColor.grey100,
//                     isDense: true,
//                     contentPadding:
//                         const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(22),
//                       borderSide: BorderSide(color: AllColor.grey200),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(22),
//                       borderSide: BorderSide(color: AllColor.grey200),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(22),
//                       borderSide: BorderSide(color: AllColor.blue500),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // Tabs (Pending selected)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     _TabChip(
//                       text: 'Pending',
//                       selected: _tab == 0,
//                       onTap: () => setState(() => _tab = 0),
//                     ),
//                     const SizedBox(width: 8),
//                     _TabChip(
//                       text: 'Completed',
//                       selected: _tab == 1,
//                       onTap: () => setState(() => _tab = 1),
//                     ),
//                     const SizedBox(width: 8),
//                     _TabChip(
//                       text: 'Cancelled',
//                       selected: _tab == 2,
//                       onTap: () => setState(() => _tab = 2),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // List
//               Expanded(
//                 child: ListView.separated(
//                   padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: items.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 12),
//                   itemBuilder: (_, i) => _ShipmentCard(
//                     data: items[i],
//                     selected: _selectedIndex == i,
//                     onTap: () => setState(() => _selectedIndex = i),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /* ============================ Models & demo data ============================ */
//
// class ShipmentItem {
//   final String orderNo;
//   final String title;
//   final String customer;
//   final String address;
//   final int qty;
//   final String date;
//   final double price;
//   final String imageUrl;
//
//   const ShipmentItem({
//     required this.orderNo,
//     required this.title,
//     required this.customer,
//     required this.address,
//     required this.qty,
//     required this.date,
//     required this.price,
//     required this.imageUrl,
//   });
// }
//
// const _demoOrders = <ShipmentItem>[
//   ShipmentItem(
//     orderNo: '12345',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     address: '6391 Elgin St. Celina,',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//         'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600',
//   ),
//   ShipmentItem(
//     orderNo: '12345',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     address: '6391 Elgin St. Celina,',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//         'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
//   ),
//   ShipmentItem(
//     orderNo: '12345',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     address: '6391 Elgin St. Celina,',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//         'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
//   ),
// ];
//
// /* ================================= UI pieces ================================ */
//
// class _SegmentedToggle extends StatelessWidget {
//   final String leftText;
//   final String rightText;
//   final int value; // 0/1
//   final ValueChanged<int> onChanged;
//
//   const _SegmentedToggle({
//     required this.leftText,
//     required this.rightText,
//     required this.value,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     Widget seg(String text, bool active, VoidCallback onTap) {
//       return Expanded(
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             height: 38,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: active ? AllColor.loginButtomColor : AllColor.white,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: active ? AllColor.loginButtomColor : AllColor.grey200,
//               ),
//               boxShadow: active
//                   ? [
//                       BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 6,
//                           offset: const Offset(0, 2))
//                     ]
//                   : null,
//             ),
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: active ? AllColor.white : AllColor.black,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Row(
//       children: [
//         seg(leftText, value == 0, () => onChanged(0)),
//         const SizedBox(width: 8),
//         seg(rightText, value == 1, () => onChanged(1)),
//       ],
//     );
//   }
// }
//
// class _TabChip extends StatelessWidget {
//   final String text;
//   final bool selected;
//   final VoidCallback onTap;
//   const _TabChip({required this.text, required this.selected, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//         decoration: BoxDecoration(
//           color: selected ? AllColor.loginButtomColor : AllColor.grey100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected ? AllColor.loginButtomColor : AllColor.grey200,
//           ),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: selected ? AllColor.white : AllColor.black,
//             fontWeight: FontWeight.w700,
//             fontSize: 13,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ShipmentCard extends StatelessWidget {
//   final ShipmentItem data;
//   final bool selected;
//   final VoidCallback onTap;
//   const _ShipmentCard({
//     required this.data,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final border = selected
//         ? Border.all(color: AllColor.blue500, width: 2)
//         : Border.all(color: AllColor.grey200);
//
//     return Material(
//       color: AllColor.transparent,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AllColor.white,
//             borderRadius: BorderRadius.circular(12),
//             border: border,
//           ),
//           padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top: order no + orange Pending pill
//               Row(
//                 children: [
//                   Text('Order #${data.orderNo}',
//                       style: TextStyle(
//                           color: AllColor.black, fontWeight: FontWeight.w700)),
//                   const Spacer(),
//                   _StatusPill(text: 'Pending', color: AllColor.loginButtomColor),
//                 ],
//               ),
//               const SizedBox(height: 10),
//
//               // Middle: image + info + price
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       height: 56,
//                       width: 56,
//                       color: AllColor.grey100,
//                       child: Image.network(data.imageUrl, fit: BoxFit.cover),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(data.title,
//                             style: TextStyle(
//                                 color: AllColor.black,
//                                 fontWeight: FontWeight.w700)),
//                         const SizedBox(height: 6),
//                         Text(data.customer,
//                             style: TextStyle(
//                                 color: AllColor.black,
//                                 fontWeight: FontWeight.w700)),
//                         Text(data.address,
//                             style: TextStyle(color: AllColor.black54)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('\$${data.price.toStringAsFixed(0)}',
//                       style: TextStyle(
//                           color: AllColor.black,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 18)),
//                 ],
//               ),
//
//               const SizedBox(height: 10),
//               Text('Qty: ${data.qty}', style: TextStyle(color: AllColor.black54)),
//               const SizedBox(height: 6),
//               Text('Order placed on ${data.date}',
//                   style: TextStyle(color: AllColor.black54, fontSize: 12)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _StatusPill extends StatelessWidget {
//   final String text;
//   final Color color;
//   const _StatusPill({required this.text, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.12),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color),
//       ),
//       child: Text(
//         text,
//         style:
//             TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
//       ),
//     );
//   }
// }