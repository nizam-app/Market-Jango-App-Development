import 'package:flutter/material.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorEditProfile extends StatefulWidget {
  const VendorEditProfile({super.key});
  static const routeName = "/vendorEditProfile";

  @override
  State<VendorEditProfile> createState() => _VendorEditProfileState();
}

class _VendorEditProfileState extends State<VendorEditProfile> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String? _selectedRoute;

  final List<String> _availableRoutes = const [
    'Austin',
    'Fairfield',
    'Naperville',
    'Orange',
    'Toledo',
  ];

  final List<String> _savedRoutes = [
    'Austin',
    'Fairfield',
    'Naperville',
    'Orange',
    'Toledo',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomBackButton(),  
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: AllColor.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your Profile',
                      style: TextStyle(
                        color: AllColor.textHintColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),

                    /// Avatar + edit badge
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/women/68.jpg",
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: AllColor.blue500,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AllColor.white,
                                  width: 2,
                                ),
                              ),
                              child: InkWell(
                                onTap: (){
                                  // imagage upload ; 
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: AllColor.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// Name
                    _Label('Name'),
                    _RoundedField(
                      controller: _name,
                      hint: 'Enter your full name',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 14),

                    /// Email
                    _Label('Email'),
                    _RoundedField(
                      controller: _email,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    /// Phone
                    _Label('Phone number'),
                    _RoundedField(
                      controller: _phone,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    /// Add Driver Routes (dropdown)
                    _Label('Add Driver Routes'),
                    _RoundedDropdown<String>(
                      value: _selectedRoute,
                      hint: 'Choose your driving routes',
                      items: _availableRoutes
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null && !_savedRoutes.contains(v)) {
                          setState(() {
                            _selectedRoute = v;
                            _savedRoutes.add(v);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    /// Save Driver Routes (clickable chips)
                    _Label('Save Driver Routes'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _savedRoutes
                          .map(
                            (route) => _RouteChip(
                              text: route,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "You clicked on $route route",
                                    ),
                                  ),
                                );
                              },
                              onRemove: () {
                                setState(() {
                                  _savedRoutes.remove(route);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    /// Save button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AllColor.loginButtomColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            color: AllColor.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

        
          ],
        ),
      ),
    );
  }



  void _onSave() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes saved')));
  }
}

/* -------------------- Small UI pieces -------------------- */

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AllColor.black,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _RoundedField({
    required this.controller,
    required this.hint,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AllColor.textHintColor),
        filled: true,
        fillColor: AllColor.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AllColor.blue500),
        ),
      ),
    );
  }
}

class _RoundedDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _RoundedDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AllColor.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AllColor.textHintColor),
        filled: true,
        fillColor: AllColor.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AllColor.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AllColor.blue500),
        ),
      ),
      dropdownColor: AllColor.white,
    );
  }
}

class _RouteChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RouteChip({
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        label: Text(
          text,
          style: TextStyle(
            color: AllColor.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        backgroundColor: AllColor.grey100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AllColor.grey200),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
      ),
    );
  }
}
