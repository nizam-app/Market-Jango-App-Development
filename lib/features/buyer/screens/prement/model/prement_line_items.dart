// lib/features/buyer/screens/prement/model/payment_status_result.dart
class PaymentStatusResult {
  final bool success;
  final Map<String, dynamic>? payload; // server JSON

  const PaymentStatusResult({required this.success, this.payload});
}