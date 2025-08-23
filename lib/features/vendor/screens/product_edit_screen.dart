import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/constants/image_control/image_path.dart';

import '../widgets/custom_back_button.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key});

  static const String routeName = '/vendor_product_edit';

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 439.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage( '${ImagePath.justForYouImage}'), fit: BoxFit.cover,)
                    ),

                  ),
                  Positioned(
                    top: 50,
                      left: 30,
                      child: CustomBackButton())
                ],
              ),
              SizedBox(height: 10.h,),
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                    itemBuilder: (context,index){
                    return Container(
                      height: 76.w,
                      width: 76.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/imgF.png"))
                      ),
                      child: Icon(Icons.camera_alt_outlined,color: Colors.white,),
                    );

                    }, separatorBuilder: ( context,  position) {
                    return SizedBox(width: 10.w,);
                },),
              ),
              SizedBox(height: 10.w,),
              Container(
                width: 350.w,
                height: 60.h,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Fashion / Trend Loop"),
                    Icon(Icons.keyboard_arrow_down)
                  ],
                ),
              ),
              SizedBox(height: 10.w,),
              Container(
                width: 350.w,
                height: 60.h,
                color: Colors.white,
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 8.w,vertical: 15.h),
                  child: Text("Women scart"),
                ),
              ),
              SizedBox(height: 10.w,),
              Container(
                width: 351.w,
                height: 226.h,
                color: Colors.white,
                child:  Center(child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text("Discover a curated collection of stylish and fashionable women’s dresses designed for every mood and moment. From elegant evenings to everyday charm — dress to express.\n\nDiscover a curated collection of stylish and fashionable women’s dresses."),
                )),

              ),
              SizedBox(height: 10.w,),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: 350.w,
                        height: 60.h,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text("Blue"),
                            ),
                            Icon(Icons.keyboard_arrow_down)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w,),
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: 350.w,
                        height: 60.h,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:  EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text("M,XL,L"),
                            ),
                            Icon(Icons.keyboard_arrow_down)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.w,),
              Container(
                width: 350.w,
                height: 60.h,
                color: Colors.white,
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 8.w,vertical: 15.h),
                  child: Text("\$18.00"),
                ),
              ),
              SizedBox(height: 20.h,),
              
              ElevatedButton(onPressed: (){},
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AllColor.loginButtomColor),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    fixedSize: WidgetStatePropertyAll(Size.fromWidth(80.w),),
                    shape:WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r)
                      )
                    )
                  ),
                  child: Text("Save"))
              

            ],
          ),
        ),
      ),

    );
  }
}
