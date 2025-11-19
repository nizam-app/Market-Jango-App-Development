// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:market_jango/core/constants/color_control/all_color.dart';
// import 'package:market_jango/core/widget/custom_auth_button.dart';
//
// class VendorOrderPending extends StatefulWidget {
//   const VendorOrderPending({super.key});
//   static const routeName = "/vendorOrderPending";
//
//   @override
//   State<VendorOrderPending> createState() => _VendorOrderPendingState();
// }
//
// class _VendorOrderPendingState extends State<VendorOrderPending> {
//   final _search = TextEditingController();
//   int _tab = 0;
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
//         .where(
//           (e) => _tab == 0
//           ? e.status == OrderStatus.pending
//           : _tab == 1
//           ? e.status == OrderStatus.assigned
//           : e.status == OrderStatus.completed,
//     )
//         .where(
//           (e) =>
//       _search.text.isEmpty ||
//           e.orderNo.toLowerCase().contains(_search.text.toLowerCase()),
//     )
//         .toList();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             CustomBackButton(),
//             SizedBox(height: 20.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.h),
//               child: _SearchField(
//                 controller: _search,
//                 hint: 'Search you product',
//                 onChanged: (_) => setState(() {}),
//               ),
//             ),
//             SizedBox(height: 12.h),
//             // Tabs
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.h),
//               child: _Tabs(
//                 current: _tab,
//                 onChanged: (i) => setState(() => _tab = i),
//               ),
//             ),
//             SizedBox(height: 12.h),
//
//             // List
//             Expanded(
//               child: ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: items.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (_, i) => _OrderCard(data: items[i]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /* -------------------- Models & Demo Data -------------------- */
//
// enum OrderStatus { pending, assigned, completed }
//
// class OrderData {
//   final String orderNo;
//   final String title;
//   final String customer;
//   final String phone;
//   final int qty;
//   final String date;
//   final double price;
//   final String imageUrl;
//   final OrderStatus status;
//
//   const OrderData({
//     required this.orderNo,
//     required this.title,
//     required this.customer,
//     required this.phone,
//     required this.qty,
//     required this.date,
//     required this.price,
//     required this.imageUrl,
//     required this.status,
//   });
// }
//
// const _demoOrders = <OrderData>[
//   OrderData(
//     orderNo: '12345',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     phone: '+00123456789',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//     'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600', // placeholder tee
//     status: OrderStatus.pending,
//   ),
//   OrderData(
//     orderNo: '12346',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     phone: '+00123456789',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//     'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
//     status: OrderStatus.pending,
//   ),
//   OrderData(
//     orderNo: '12347',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     phone: '+00123456789',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//     'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
//     status: OrderStatus.pending,
//   ),
//
//   OrderData(
//     orderNo: '12348',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     phone: '+00123456789',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//     'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
//     status: OrderStatus.pending,
//   ),
// ];
//
// /* -------------------- UI Pieces -------------------- */
//
// class _SearchField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final ValueChanged<String>? onChanged;
//   const _SearchField({
//     required this.controller,
//     required this.hint,
//     this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       onChanged: onChanged,
//       textInputAction: TextInputAction.search,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: AllColor.textHintColor),
//         prefixIcon: Icon(Icons.search_rounded, color: AllColor.black54),
//         filled: true,
//         fillColor: AllColor.grey100,
//         isDense: true,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(22),
//           borderSide: BorderSide(color: AllColor.grey200),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(22),
//           borderSide: BorderSide(color: AllColor.grey200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(22),
//           borderSide: BorderSide(color: AllColor.blue500),
//         ),
//       ),
//     );
//   }
// }
//
// class _Tabs extends StatelessWidget {
//   final int current; // 0..2
//   final ValueChanged<int> onChanged;
//   const _Tabs({required this.current, required this.onChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     Widget chip(String text, int index, {VoidCallback? onTap}) {
//       final selected = current == index;
//       return InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap ?? () => onChanged(index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//           decoration: BoxDecoration(
//             color: selected ? AllColor.loginButtomColor : AllColor.grey100,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: selected ? AllColor.loginButtomColor : AllColor.grey200,
//             ),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               color: selected ? AllColor.white : AllColor.black,
//               fontWeight: FontWeight.w700,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Row(
//       children: [
//         chip('Pending', 0),
//         SizedBox(width: 8.h),
//         chip(
//           'Assigned order',
//           1,
//           onTap: () {
//             context.push("/vendorOrderAssigned");
//           },
//         ),
//         SizedBox(width: 8.h),
//         chip(
//           'Completed',
//           2,
//           onTap: () {
//             context.push("/vendorOrderCompleted");
//           },
//         ),
//       ],
//     );
//   }
// }
//
// class _OrderCard extends StatelessWidget {
//   final OrderData data;
//   const _OrderCard({required this.data});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AllColor.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AllColor.grey200),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 2,
//             offset: Offset(0, .5),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Order #${data.orderNo}',
//                 style: TextStyle(
//                   color: AllColor.black,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               InkWell(
//                 onTap: () {},
//
//                 child: _StatusPill(
//                   text: 'Pending',
//                   color: AllColor.loginButtomColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Container(
//                   height: 64.h,
//                   width: 64.w,
//                   color: AllColor.grey100,
//                   child: Image.network(data.imageUrl, fit: BoxFit.cover),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data.title,
//                       style: TextStyle(
//                         color: AllColor.black,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     SizedBox(height: 6.h),
//                     Text(
//                       data.customer,
//                       style: TextStyle(
//                         color: AllColor.black,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     Text(data.phone, style: TextStyle(color: AllColor.black54)),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 8.w),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Qty: ${data.qty}',
//                 style: TextStyle(color: AllColor.black54),
//               ),
//               Text(
//                 '\$${data.price.toStringAsFixed(0)}',
//                 style: TextStyle(
//                   color: AllColor.black,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 18.sp,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             'Order placed on ${data.date}',
//             style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
//           ),
//         ],
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
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: AllColor.white,
//           fontWeight: FontWeight.w700,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
// }