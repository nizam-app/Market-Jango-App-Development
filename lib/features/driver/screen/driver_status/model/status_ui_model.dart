// status_ui_model.dart
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_details_model.dart';

enum TrackingStep { packed, cashReceive, confirmDelivery }

class TrackingUi {
  final int currentStep; // stepper er jonno
  final bool packedChecked;
  final String? packedNote;

  final bool showCashStep;
  final bool cashChecked;
  final String? cashNote;

  final bool confirmChecked;
  final String? confirmNote;

  final bool cancelChecked;
  final String? cancelNote;

  final bool showCancel;
  final TrackingStep? editableStep;

  TrackingUi({
    required this.currentStep,
    required this.packedChecked,
    required this.packedNote,
    required this.showCashStep,
    required this.cashChecked,
    required this.cashNote,
    required this.confirmChecked,
    required this.confirmNote,
    required this.cancelChecked,
    required this.cancelNote,
    required this.showCancel,
    required this.editableStep,
  });
}

TrackingUi buildTrackingUi(DriverTrackingData data) {
  final status = (data.status ?? '')
      .trim(); // AssignedOrder / On The Way / Ready for delivery / Complete / Not Deliver
  final note = data.note;
  final paymentMethod =
      (data.invoice?.paymentMethod ?? data.invoice?.paymentMethod ?? '')
          .toUpperCase();
  final isOpu = paymentMethod == 'OPU';

  bool packedChecked = false;
  bool cashChecked = false;
  bool confirmChecked = false;
  bool cancelChecked = false;

  String? packedNote;
  String? cashNote;
  String? confirmNote;
  String? cancelNote;

  bool showCancel = true;
  TrackingStep? editableStep;
  int currentStep = 1;

  switch (status) {
    case 'AssignedOrder':
    case 'Pending':
      currentStep = 1;
      editableStep = TrackingStep.packed;
      break;

    case 'On The Way':
      // 👉 Packed done, note under Packed
      currentStep = isOpu ? 2 : 2;
      packedChecked = true;
      packedNote = note;
      // OPU হলে এখন cash step editable, নাহলে confirm editable
      editableStep = isOpu
          ? TrackingStep.cashReceive
          : TrackingStep.confirmDelivery;
      break;

    case 'Ready for delivery':
      // 👉 Cash receive done, note under Cash
      currentStep = isOpu ? 3 : 2;
      packedChecked = true;
      cashChecked = true;
      cashNote = note;
      editableStep = TrackingStep.confirmDelivery;
      break;

    case 'Complete':
      currentStep = isOpu ? 4 : 3;
      packedChecked = true;
      if (isOpu) cashChecked = true;
      confirmChecked = true;
      confirmNote = note;
      showCancel = false;
      editableStep = null;
      break;

    case 'Not Deliver':
      currentStep = isOpu ? 4 : 3;
      cancelChecked = true;
      cancelNote = note;
      showCancel = false;
      editableStep = null;
      break;

    default:
      editableStep = TrackingStep.packed;
  }

  return TrackingUi(
    currentStep: currentStep,
    packedChecked: packedChecked,
    packedNote: packedNote,
    showCashStep: isOpu,
    cashChecked: cashChecked,
    cashNote: cashNote,
    confirmChecked: confirmChecked,
    confirmNote: confirmNote,
    cancelChecked: cancelChecked,
    cancelNote: cancelNote,
    showCancel: showCancel,
    editableStep: editableStep,
  );
}
