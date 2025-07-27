import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  
  static const String routeName = '/account_screen';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text("Account "),
      ),
    );
  }
}