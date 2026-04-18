/// Shared rules for when vendor UI may assign a driver to an order line.
class VendorOrderAssignRules {
  VendorOrderAssignRules._();

  /// Same gate as marketplace / manual fulfilment sheets.
  static bool sheetAllowsAssignDriver(
    String invoiceGateStatus,
    String lineStatus,
  ) {
    if (isPendingOrProcessingStatus(lineStatus)) return true;
    return isPendingOrProcessingStatus(invoiceGateStatus) &&
        isPendingOrProcessingStatus(lineStatus);
  }

  /// Matches server rule: assign-driver only when order + line are pending/processing.
  static bool isPendingOrProcessingStatus(String? raw) {
    final s =
        raw?.toLowerCase().trim().replaceAll(RegExp(r'[\s_\-]+'), '') ?? '';
    if (s.isEmpty) return false;
    return s == 'pending' ||
        s == 'processing' ||
        s == 'inprocess' ||
        s == 'inprogress';
  }
}
