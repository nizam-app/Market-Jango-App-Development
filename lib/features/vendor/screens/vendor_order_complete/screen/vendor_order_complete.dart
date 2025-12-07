// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:market_jango/core/constants/color_control/all_color.dart';
// import 'package:market_jango/core/widget/custom_auth_button.dart';
//
// class VendorOrderComplete extends StatefulWidget {
//   const VendorOrderComplete({super.key});
//   static const routeName = "/vendorOrderCompleted";
//
//   @override
//   State<VendorOrderComplete> createState() => _VendorOrderCompleteState();
// }
//
// class _VendorOrderCompleteState extends State<VendorOrderComplete> {
//   final _search = TextEditingController();
//   int _tab = 2;
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
//           (e) =>
//               _search.text.trim().isEmpty ||
//               e.orderNo.toLowerCase().contains(_search.text.toLowerCase()),
//         )
//         .toList();
//
//     return Scaffold(
//       backgroundColor: AllColor.white,
//
//       body: SafeArea(
//         child: Column(
//           children: [
//             CustomBackButton(),
//             SizedBox(height: 20.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: _SearchField(
//                 controller: _search,
//                 hint: 'Search you product',
//                 onChanged: (_) => setState(() {}),
//               ),
//             ),
//             12.h.verticalSpace,
//
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.h),
//               child: _Tabs(
//                 current: _tab,
//                 onChanged: (i) => setState(() => _tab = i),
//               ),
//             ),
//             12.h.verticalSpace,
//             Expanded(
//               child: ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: items.length,
//                 separatorBuilder: (_, __) => SizedBox(height: 12.h),
//                 itemBuilder: (_, i) => _OrderCard(data: items[i], onTap: () {
//
//                 }),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /* ===================== Models & Demo Data ===================== */
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
//         'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600',
//   ),
//   OrderData(
//     orderNo: '12345',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     phone: '+00123456789',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//         'https://images.unsplash.com/photo-1519741497674-611481863552?w=600',
//   ),
//   OrderData(
//     orderNo: '12345',
//     title: 'Balack t shirt x1\nwhite shoe x3',
//     customer: 'John doe',
//     phone: '+00123456789',
//     qty: 4,
//     date: '10 july 2025',
//     price: 120,
//     imageUrl:
//         'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600',
//   ),
// ];
//
// /* ===================== UI Pieces ===================== */
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
//       style: TextStyle(fontSize: 14.sp),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: AllColor.textHintColor, fontSize: 13.sp),
//         prefixIcon: Icon(
//           Icons.search_rounded,
//           color: AllColor.black54,
//           size: 20.r,
//         ),
//         filled: true,
//         fillColor: AllColor.grey100,
//         isDense: true,
//         contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(22.r),
//           borderSide: BorderSide(color: AllColor.grey200),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(22.r),
//           borderSide: BorderSide(color: AllColor.grey200),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(22.r),
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
//         borderRadius: BorderRadius.circular(20.r),
//         onTap:
//             onTap ?? () => onChanged(index), // priority: custom onTap > default
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
//           decoration: BoxDecoration(
//             color: selected ? AllColor.loginButtomColor : AllColor.grey100,
//             borderRadius: BorderRadius.circular(20.r),
//             border: Border.all(
//               color: selected ? AllColor.loginButtomColor : AllColor.grey200,
//             ),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               color: selected ? AllColor.white : AllColor.black,
//               fontWeight: FontWeight.w700,
//               fontSize: 13.sp,
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Row(
//       children: [
//         InkWell(
//           onTap: () {
//             context.push("/vendorOrderPending");
//           },
//           child: chip('Pending', 0),
//         ),
//         SizedBox(width: 8.w),
//         chip(
//           'Assigned order',
//           1,
//           onTap: () {
//             context.push("/vendorOrderAssigned");
//           },
//         ),
//         SizedBox(width: 8.w),
//         chip('Completed', 2),
//       ],
//     );
//   }
// }
//
// class _OrderCard extends StatelessWidget {
//   final OrderData data;
//   final VoidCallback onTap;
//   const _OrderCard({required this.data, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: AllColor.transparent,
//       borderRadius: BorderRadius.circular(12.r),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: onTap, // GoRouter to details
//         child: Container(
//           decoration: BoxDecoration(
//             color: AllColor.white,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: AllColor.grey200),
//           ),
//           padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Order #${data.orderNo}',
//                     style: TextStyle(
//                       color: AllColor.black,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                        context.push("/vendorOrderCancel");
//                     },
//                     child: _StatusPill(
//                       text: 'Complete',
//                       color: AllColor.black,
//                     ),
//                   ),
//                 ],
//               ),
//               10.h.verticalSpace,
//               // Middle: image + info + price
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8.r),
//                     child: Container(
//                       height: 64.r,
//                       width: 64.r,
//                       color: AllColor.grey100,
//                       child: Image.network(data.imageUrl, fit: BoxFit.cover),
//                     ),
//                   ),
//                   10.w.horizontalSpace,
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           data.title,
//                           style: TextStyle(
//                             color: AllColor.black,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                         6.h.verticalSpace,
//                         Text(
//                           data.customer,
//                           style: TextStyle(
//                             color: AllColor.black,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 13.sp,
//                           ),
//                         ),
//                         Text(
//                           data.phone,
//                           style: TextStyle(
//                             color: AllColor.black54,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   8.w.horizontalSpace,
//                 ],
//               ),
//               10.h.verticalSpace,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Qty: ${data.qty}',
//                     style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
//                   ),
//                   Text(
//                     '\$${data.price.toStringAsFixed(0)}',
//                     style: TextStyle(
//                       color: AllColor.black,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 18.sp,
//                     ),
//                   ),
//                 ],
//               ),
//               6.h.verticalSpace,
//               Text(
//                 'Order placed on ${data.date}',
//                 style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
//               ),
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
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//       decoration: BoxDecoration(
//         color: Colors.green,
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: color),
//
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.w700,
//           fontSize: 12.sp,
//         ),
//       ),
//     );
//   }
// }