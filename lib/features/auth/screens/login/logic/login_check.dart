// import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/driver_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';

enum Role { buyer, transport, vendor, driver }

class User {
  final String email, phone, password;
  final Role role;
  const User(this.email, this.phone, this.password, this.role);
}

// Demo list (API দিলে এটা বাদ দিন)
final users = <User>[
  User('buyer@mail.com',  '+15550001', 'buyer123', Role.buyer),
  User('vendor@mail.com', '+15550002', 'vendor123', Role.vendor),
  User('driver@mail.com', '+15550003', 'driver123', Role.driver),
  User('transport@mail.com',  '+15550004', 'transport123', Role.transport),
];

String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');
String _routeFor(Role r) => switch (r) {
  Role.buyer     => BuyerBottomNavBar.routeName,
  Role.transport => TransportBottomNavBar.routeName,
  Role.vendor    => VendorBottomNav.routeName,
  Role.driver    => DriverBottomNavBar.routeName,
};

/// ✅ Single-role login + navigate
Future<void> loginAndGoSingleRole(
    BuildContext context, {
      required String id,        // email or phone
      required String password,
    }) async {
  id = id.trim();
  if (id.isEmpty || password.isEmpty) throw Exception('Enter email/phone and password');

  final isEmail = id.contains('@');

  final u = users.firstWhere(
        (e) => isEmail
        ? e.email.toLowerCase() == id.toLowerCase()
        : _digits(e.phone) == _digits(id),
    orElse: () => throw Exception('Account not found'),
  );

  if (u.password != password) throw Exception('Wrong password');

  // একটাই রোল, তাই সরাসরি ওই রুটে যাও
  context.go(_routeFor(u.role));
}