import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/features/buyer/screens/cart/data/visibility_locations_data.dart';
import 'package:market_jango/features/buyer/screens/filter/data/visibility_vendors_data.dart';
import 'package:market_jango/features/buyer/screens/filter/screen/available_vendors_screen.dart';

class LocationFilteringTab extends ConsumerStatefulWidget {
  const LocationFilteringTab({super.key});

  @override
  ConsumerState<LocationFilteringTab> createState() =>
      _LocationFilteringTabState();
}

class _LocationFilteringTabState extends ConsumerState<LocationFilteringTab> {
  String? _selectedZone;
  String? _selectedTown;
  late final TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    _stateController = TextEditingController();
  }

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.32),
      body: Stack(
        children: [
          Opacity(opacity: 0.4, child: Container(color: Colors.black)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AllColor.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  /// Location
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      //"Enter your Location"
                      ref.t(BKeys.enterLocation),
                      style: theme.headlineMedium!.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ref.watch(visibilityZonesProvider).when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text(
                          e.toString().replaceFirst('Exception: ', ''),
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                        data: (zones) => DropdownButtonFormField<String>(
                          value: _selectedZone != null &&
                                  zones.contains(_selectedZone)
                              ? _selectedZone
                              : null,
                          decoration: buildInputDecoration(),
                          hint: Text(ref.t(BKeys.searchLocation)),
                          items: zones
                              .map(
                                (z) => DropdownMenuItem<String>(
                                  value: z,
                                  child: Text(z),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedZone = v;
                              _selectedTown = null;
                            });
                          },
                        ),
                      ),

                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'State',
                      style: theme.headlineMedium!.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  TextField(
                    controller: _stateController,
                    enabled: (_selectedZone ?? '').trim().isNotEmpty,
                    textCapitalization: TextCapitalization.words,
                    decoration: buildInputDecoration().copyWith(
                      hintText: 'Type state (optional)',
                    ),
                  ),

                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Town',
                      style: theme.headlineMedium!.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ref
                      .watch(
                        visibilityTownsByZoneProvider(
                          (_selectedZone ?? '').trim(),
                        ),
                      )
                      .when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => DropdownButtonFormField<String>(
                          decoration: buildInputDecoration(),
                          items: const [],
                          onChanged: null,
                          hint: Text(
                            e.toString().replaceFirst('Exception: ', ''),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        data: (towns) => DropdownButtonFormField<String>(
                          value: _selectedTown != null &&
                                  towns.contains(_selectedTown)
                              ? _selectedTown
                              : null,
                          decoration: buildInputDecoration(),
                          hint: const Text('Select town'),
                          items: towns
                              .map(
                                (t) => DropdownMenuItem<String>(
                                  value: t,
                                  child: Text(t),
                                ),
                              )
                              .toList(),
                          onChanged: ((_selectedZone ?? '').trim().isEmpty)
                              ? null
                              : (v) => setState(() => _selectedTown = v),
                        ),
                      ),

                  SizedBox(height: 20.h),

                  /// Apply button - call API and show products
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        final zone = (_selectedZone ?? '').trim();
                        final st = _stateController.text.trim();
                        final town = (_selectedTown ?? '').trim();

                        if (zone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter your location'),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        context.push(
                          AvailableVendorsScreen.routeName,
                          extra: VisibilityVendorsParams(
                            zone: zone,
                            state: st.isEmpty ? null : st,
                            town: town.isEmpty ? null : town,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColor.loginButtomColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AllColor.dropDown,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}
