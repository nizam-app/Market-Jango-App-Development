// features/driver/screen/driver_status/model/status_ui_model.dart

import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_details_model.dart';

enum TrackingStep { none, packed, confirmDelivery }

class TrackingUiModel {
  final bool packedChecked;
  final bool confirmChecked;
  final bool cancelChecked;

  final String? packedNote;
  final String? confirmNote;
  final String? cancelNote;

  /// stepper er jonno (1..3)
  final int currentStep;

  /// kon step e user tick / note edit korte parbe
  final TrackingStep editableStep;

  /// Cancel row + bottom Cancel button dekhabo kina
  final bool showCancel;

  const TrackingUiModel({
    required this.packedChecked,
    required this.confirmChecked,
    required this.cancelChecked,
    required this.packedNote,
    required this.confirmNote,
    required this.cancelNote,
    required this.currentStep,
    required this.editableStep,
    required this.showCancel,
  });
}

String _norm(String s) => s.toLowerCase().trim();

/// Ei function e shob rule boshiye dilam
TrackingUiModel buildTrackingUi(DriverTrackingData data) {
  final s = _norm(data.status);

  bool packedChecked = false;
  bool confirmChecked = false;
  bool cancelChecked = false;

  String? packedNote;
  String? confirmNote;
  String? cancelNote;

  int currentStep = 1;
  TrackingStep editableStep = TrackingStep.none;
  bool showCancel = true;

  if (s == 'complete' || s == 'completed') {
    // ✅ Complete
    packedChecked = true;
    confirmChecked = true;
    confirmNote = data.note;

    currentStep = 3; // stepper full
    editableStep = TrackingStep.none;
    showCancel = false; // cancel button / row non-editable
  } else if (s == 'on the way') {
    // ✅ On The Way → Packed tick + note under Packed
    packedChecked = true;
    packedNote = data.note;

    currentStep = 2; // middle dot porjonto
    editableStep = TrackingStep.confirmDelivery; // ekhon Confirm editable
    showCancel = true;
  } else if (s == 'not deliver') {
    // ❌ Not Deliver (cancelled)
    cancelChecked = true;
    cancelNote = data.note;

    currentStep = 1; // delivery hoy nai
    editableStep = TrackingStep.none;
    showCancel = false; // abar cancel kora jabe na
  } else {
    // Others → Pending dhore nilam
    packedChecked = false;
    confirmChecked = false;

    currentStep = 1;
    editableStep = TrackingStep.packed; // prothom step editable
    showCancel = true;
  }

  return TrackingUiModel(
    packedChecked: packedChecked,
    confirmChecked: confirmChecked,
    cancelChecked: cancelChecked,
    packedNote: packedNote,
    confirmNote: confirmNote,
    cancelNote: cancelNote,
    currentStep: currentStep,
    editableStep: editableStep,
    showCancel: showCancel,
  );
}
