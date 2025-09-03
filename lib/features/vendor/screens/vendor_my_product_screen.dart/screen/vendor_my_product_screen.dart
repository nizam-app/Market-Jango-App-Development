import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class VendorMyProductScreen extends StatefulWidget {
  const VendorMyProductScreen({super.key});
  static const routeName = "/vendorMyProductScreen";

  @override
  State<VendorMyProductScreen> createState() => _VendorMyProductScreenState();
}

class _VendorMyProductScreenState extends State<VendorMyProductScreen> {
  final List<String> attributes = [];

  void _showAttributeMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
         PopupMenuItem(value: "Color", child: InkWell(
          onTap: (){
            context.push("/vendorProductColor");
          },
          child: Text("Color"))),
         PopupMenuItem(value: "Size", child: InkWell(
          onTap: (){
            context.push("/myProductSizeScreen");
          },
          child: Text("Size"))),
         PopupMenuItem(value: "Number", child: InkWell(
          onTap: (){
            context.push("/vendorProductColorName"); 
          },
          child: Text("Number"))),
         PopupMenuItem(value: "Others", child: Text("Others")),
      ],
    );

    if (value != null) {
      setState(() {
        attributes.add(value);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$value attribute added!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton(),
              Text(
                "My Products",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),

              /// Add Product and Add Category
              Row(
                children: [
                  _AddBox(
                    title: "Add your\nProduct",
                    onTap: () {
                      context.push("/productEditePage");
                    },
                  ),
                  SizedBox(width: 12.w),
                  _AddBox(
                    title: "Add your\nCategory",
                    onTap: () {
                      context.push("/categoryAddPage");
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              /// Add custom attribute
              GestureDetector(
                onTap: () {
                  context.push("");
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Text("Add your custom attribute"),
                      
                      InkWell(
                        onTapDown: (details){
                          _showAttributeMenu(context, details.globalPosition);
                        },
                        child: Container(
                          height: 20.w,
                          width: 100.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey,width: 1)
                          ),
                        ),
                      ), 
                      InkWell(
                        onTap: (){

                        },
                        child: Icon(Icons.add)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Products List
              Text(
                "Products List",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12.h),

              /// Product items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  return _ProductCard(
                    imageUrl:
                        "lib/features/vendor/screens/vendor_order_complete/screen/vendor_order_complete.dart",
                    title: "Flowy summer dress",
                    category: "Fashion",
                    price: "\$65",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Add Box Widget
class _AddBox extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AddBox({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 30),
              SizedBox(height: 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product Card
class _ProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;
  final String imageUrl;

  const _ProductCard({
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: 64.r,
              width: 64.r,
              color: AllColor.grey100,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          /// Price
          Text(
            price,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 6.w),

          InkWell(
            onTapDown: (TapDownDetails details) {
              _showPopupMenu(context, details.globalPosition);
            },
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  void _showPopupMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // X position = icon position
        position.dy, // Y position = icon position
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem(
          value: "edit",
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black),
              SizedBox(width: 8.w),
              Text("Edit"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "delete",
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.black),
              SizedBox(width: 8.w),
              Text("Delete"),
            ],
          ),
        ),
      ],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (value == "edit") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Edit clicked")));
    } else if (value == "delete") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Delete clicked")));
    }
  }
}
