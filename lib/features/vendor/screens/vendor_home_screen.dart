import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/custom_search_bar.dart';
import 'package:market_jango/features/vendor/widgets/edit_widget.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  String selectedFilter = "All"; // default selected filter

  final List<String> filters = [
    "All",
    "Women",
    "Men",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white24,
        //drawer section
        endDrawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: ListView(
            children: const [
              DrawerHeader(
                child: Text("Right Drawer"),
              ),
              ListTile(title: Text("Option A")),
              ListTile(title: Text("Option B")),
            ],
          ),

        ),
        body: Builder(
          builder: (context) {
            return Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25.h),
                  Container(
                      child: Stack(
                        children: [
                          buildProfileScetion(),
                          Positioned(
                            top: 20,
                            right: 10,
                            child:  GestureDetector(
                              onTap: (){
                                Scaffold.of(context).openEndDrawer();
                              },
                              child: Container(
                                height: 46.w,
                              width: 46.w,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: Icon(Icons.menu, size: 24), // ☰ three-line menu
                                                    ),
                            ),)
                        ],
                      )),
                  SizedBox(height: 30.h),
                  CustomSearchBar(),
                  SizedBox(height: 10.h),
                  buildFilteredSection(),
                  buildProductGridViewSection()

                ],
              ),
            );
          }
        ),

      ),

    );
  }

  Widget buildFilteredSection() {
    return SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text("Fashion"),
                          Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),

                    // Filter buttons
                    buildFilter()
                  ],
                ),
              ),
            );
  }

  Widget buildFilter() {
    return Row(
                      children: filters.map((filter) {
                        bool isSelected = selectedFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AllColor.loginButtomColor : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
  }

  Widget buildProductGridViewSection() {
    return Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    childAspectRatio: 9/13,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 15
                      ),

                  itemCount: 10,
                  itemBuilder: (context,index){
                    if(index==0){
                      return buildAddUrProduct(context);
                    }
                    else{
                      return Stack(
                        children: [
                          CustomNewProduct(width: 161.w,height: 262.h,text: "Flowy summer dress", text2:  "Flowy summer dress",),
                          Positioned(
                              top: 20,
                              right: 20,
                              child: Edit_Widget(height: 24.w,width: 24.w,size: 12.r,))
                        ],
                      );
                    }


                  }),
            );
  }

  Widget buildAddUrProduct(BuildContext context) {
    return Card(
                        elevation: 1,
                        child: Container(
                          height: 244.h,
                          width: 169.w,
                          decoration: BoxDecoration(

                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              Icon(Icons.add, size: 70,color: Color(0xff575757),),
                              Text("Add your\nProduct",style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Color(0xff2F2F2F),fontWeight: FontWeight.w700))
                            ],
                          ),
                        ),
                      );
  }

  Widget buildProfileScetion() {
    return Column(
            children: [

              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 82.w,
                      width: 82.w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1.w,
                              color: AllColor.loginButtomColor
                          ),
                          image: DecorationImage(image: AssetImage("assets/images/vendor_profile.png",),fit: BoxFit.cover)
                      ),

                    ),
                    Positioned(
                        top: 15,
                        left: 8,
                        child: Container(
                          height: 10.w,
                          width: 10.w,
                          decoration: BoxDecoration(
                              color: AllColor.activityColor,
                              shape: BoxShape.circle
                          ),
                        )),
                    Positioned(
                        bottom: 10,
                        right: 0,
                        child: Edit_Widget(height: 21.w,width: 21.w,size: 10.r,))
                  ],
                ),

              ),

              SizedBox(height: 20.h),
              Text("TrendLoop",style: TextStyle(fontSize: 16.sp,color: AllColor.loginButtomColor))
            ],
          );
  }
}


