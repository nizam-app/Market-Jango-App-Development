import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/screen/profile_screen/logic/user_data_update_riverpod.dart';
import 'package:market_jango/core/screen/profile_screen/model/profile_model.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/show_shipping_address_sheet.dart';
class BuyerProfileEditScreen extends ConsumerStatefulWidget {
  const BuyerProfileEditScreen({super.key, required this.user});
  static final routeName= "/buyerProfileEditScreen";
  final UserModel user;

  @override
  ConsumerState<BuyerProfileEditScreen> createState() => _BuyerProfileEditScreenState();
}

class _BuyerProfileEditScreenState extends ConsumerState<BuyerProfileEditScreen> {


  @override
  void initState() {
    super.initState();
    // Set default value for gender dropdown
    _selectedGender = widget.user.buyer?.gender;
  }

  @override
  Widget build(BuildContext context) {

    final nameC = TextEditingController(text: widget.user.name);
    final emailC = TextEditingController(text: widget.user.email);
    final phoneC = TextEditingController(text: widget.user.phone);
    final ageC = TextEditingController(text: widget.user.buyer?.age);
    final aboutC = TextEditingController(
        text:
        widget.user.buyer?.description);
    final locationC = TextEditingController(text: widget.user.buyer?.address);
    final updateUserLoading = ref.watch(updateUserProvider).isLoading;

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  const Tuppertextandbackbutton(screenName: "My Profile") ,
                  buildStackProfileImage(widget.user.image)      ,
                  CustomTextFormField(label: "Your Name", controller: nameC),
                  SizedBox(height: 12.h),
                  CustomTextFormField(label: "Email", controller: emailC,),
                  SizedBox(height: 12.h),
                  CustomTextFormField(label: "Phone", controller: phoneC),

                  SizedBox(height: 12.h),
                  // ---- Gender & Age Row ----
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gender", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                fillColor: Color(0xffE6F0F8)
                                ,
                                hintText: "Select Gender",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: BorderSide(color: Color(0xff0168B8),width: 0.2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide:BorderSide(color: Color(0xff0168B8),width: 0.2),
                                ),focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide:BorderSide(color: Color(0xff0168B8),width: 0.2),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              ),
                              items: <String>['Male', 'Female']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomTextFormField(
                          label: "Age",
                          controller: ageC,
                          hintText: "Enter Age",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "About",
                    controller: aboutC,
                    maxLines: 3,
                  ),

                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Location",
                    controller: locationC,
                    hintText: "Enter Location",
                  ),
                  SizedBox(height: 30.h,)     ,
                  GlobalSaveBotton(bottonName:updateUserLoading? "Saving..." : "Save Changes", onPressed: ()async {
                    if (updateUserLoading) return;

                    // String? _nn(String? s) =>
                    //     (s == null || s.trim().isEmpty) ? null : s.trim();

                    final ok = await ref.read(updateUserProvider.notifier).updateUser(
                      name: nameC.text,
                      gender: _selectedGender,
                      age: ageC.text,
                      description: aboutC.text,
                      country: locationC.text.split(' ').last,
                      address: locationC.text,
                      shipCity: locationC.text.split(' ').first,
                      image: _mainImage, // File? (null হলে পানালে না)
                    );

                    if (!context.mounted) return;

                    if (ok) {
                     context.pop() ;
                     GlobalSnackbar.show(context, title: "Success", message:"Profile updated successfully");
                     ref.invalidate(userProvider);

                    } else {
                      final errMsg = ref.read(updateUserProvider).maybeWhen(
                        error: (e, __) => e.toString(),
                        orElse: () => 'Update failed',
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(errMsg)));
                    }
                  },),
                ],

                    ),
            ),
          )),
    );
  }
  String? _selectedGender;

  Stack buildStackProfileImage(image) {
    return Stack(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundImage: _mainImage != null ? FileImage(_mainImage!) : NetworkImage(image),
                ),
                Positioned(
                  bottom: 0.h,
                  right: 0.w,
                  child: InkWell(
                    onTap: (){
                      _askImageSource();
                    },
                    child: CircleAvatar(
                    
                      radius: 12.r, backgroundColor: AllColor.white,
                      child: Padding(
                        padding:  EdgeInsets.all(5.r),
                        child: Icon(Icons.camera_alt,color: AllColor.black,size: 15.sp,),
                      ),
                    ),
                  ),
                ),
              ],
            );
  }
  final ImagePicker _picker = ImagePicker();

  File? _mainImage;
  void _askImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
               
                       pickMainImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickMainImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> pickMainImage(source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => _mainImage = File(xFile.path));
    }
  }
  
}