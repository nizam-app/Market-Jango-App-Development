import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

bool _bytesLookLikePdf(Uint8List bytes) {
  return bytes.length >= 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;
}

String _extensionForDocument(Uint8List bytes, String? contentType) {
  final ct = contentType?.toLowerCase() ?? '';
  if (ct.contains('application/pdf') || _bytesLookLikePdf(bytes)) {
    return 'pdf';
  }
  if (ct.contains('text/html') || ct.contains('html')) return 'html';
  if (bytes.length >= 5) {
    final probe = bytes.length > 512 ? bytes.sublist(0, 512) : bytes;
    try {
      final head = String.fromCharCodes(probe).trimLeft().toLowerCase();
      if (head.startsWith('<!doctype') || head.startsWith('<html')) {
        return 'html';
      }
    } catch (_) {}
  }
  // `doc/details.md` §1: successful download is PDF; unknown binary defaults to .pdf.
  return 'pdf';
}

String _mimeForExtension(String ext) {
  switch (ext) {
    case 'pdf':
      return 'application/pdf';
    case 'html':
      return 'text/html';
    default:
      return 'application/octet-stream';
  }
}

Rect? _shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  final topLeft = box.localToGlobal(Offset.zero);
  return topLeft & box.size;
}

/// Writes the document under app documents (`MarketJango/downloads`) and opens
/// the platform share sheet so the user can save to Downloads / Files / Drive.
Future<void> saveVendorOrderDocumentLocallyAndShare({
  required BuildContext context,
  required Uint8List bytes,
  required String? contentType,
  required String orderLabel,
  required bool isDeliveryLabel,
}) async {
  final shareOrigin = _shareOrigin(context);
  final ext = _extensionForDocument(bytes, contentType);
  final tag = isDeliveryLabel ? 'delivery_label' : 'invoice';
  final safeOrder = orderLabel
      .trim()
      .replaceAll(RegExp(r'[^\w\-\.]'), '_')
      .replaceAll(RegExp(r'_+'), '_');
  final base =
      safeOrder.isEmpty ? 'order' : (safeOrder.length > 40 ? safeOrder.substring(0, 40) : safeOrder);
  final ts = DateTime.now().millisecondsSinceEpoch;
  final name = '${tag}_${base}_$ts.$ext';

  final root = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(root.path, 'MarketJango', 'downloads'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final path = p.join(folder.path, name);
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);

  final mime = _mimeForExtension(ext);
  final xf = XFile(file.path, mimeType: mime, name: name);

  await SharePlus.instance.share(
    ShareParams(
      files: [xf],
      subject: isDeliveryLabel ? 'Delivery label' : 'Invoice',
      text: 'Save to Downloads or another folder.',
      sharePositionOrigin: shareOrigin,
    ),
  );
}
