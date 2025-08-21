import 'package:flutter/material.dart';

class TransportBooking extends StatefulWidget {
  const TransportBooking({super.key});
  static const String routeName = '/transport_booking';

  @override
  State<TransportBooking> createState() => _TransportBookingState();
}

class _TransportBookingState extends State<TransportBooking> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Text("Transport Booking "),
      ),
    );
  }
}