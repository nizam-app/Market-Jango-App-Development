import 'package:shared_preferences/shared_preferences.dart';

/// Last paired 58mm Bluetooth printer (XPrinter / Goojprt / HSPOS, etc.).
class VendorPrinterPrefs {
  VendorPrinterPrefs._();

  static const _macKey = 'vendor_bt58_mac';
  static const _nameKey = 'vendor_bt58_name';

  static Future<({String? mac, String? name})> saved58Printer() async {
    final p = await SharedPreferences.getInstance();
    return (mac: p.getString(_macKey), name: p.getString(_nameKey));
  }

  static Future<void> save58Printer({
    required String mac,
    required String name,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_macKey, mac);
    await p.setString(_nameKey, name);
  }
}
