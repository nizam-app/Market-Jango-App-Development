import 'package:flutter/material.dart';

class DriverSetting extends StatefulWidget {
  const DriverSetting({super.key});
  static final routeName ="/driverSetting"; 


  @override
  State<DriverSetting> createState() => _DriverSettingState();
}

class _DriverSettingState extends State<DriverSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Driver setting "),
      ),
    );
  }
}