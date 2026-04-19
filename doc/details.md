# Flutter app — order PDF download & `share_plus` (APK build)

This doc explains how the **mobile app** should call the Laravel APIs for **invoice** and **delivery label** PDFs, and how to fix the common **`MissingPluginException`** for **`share_plus`** on a **release APK**.

---

## 1. API — marketplace orders (buyer / admin / vendor / driver)

**Base URL** must include the API prefix, for example:

`https://YOUR_DOMAIN.com/api`

### Endpoints

| Action | Method | Path |
|--------|--------|------|
| Invoice PDF | `GET` | `/all/order/{id}/download-invoice` |
| Delivery label PDF | `GET` | `/all/order/{id}/download-delivery-label` |

Full examples:

- `GET https://YOUR_DOMAIN.com/api/all/order/98/download-invoice`
- `GET https://YOUR_DOMAIN.com/api/all/order/98/download-delivery-label`

### Auth (required)

Use the same JWT as login. Laravel reads the **`token`** header (not only `Authorization`):

| Header | Value |
|--------|--------|
| `token` | `Bearer eyJ...` (exact string returned from login, usually includes the word `Bearer` and a space) |

Optional: `Accept: application/pdf` — does not replace `token`.

### `{id}` rules

- **Buyer:** `{id}` = **invoice** id (same as buyer tracking `order_id`).
- **Admin / vendor / driver:** `{id}` may be **invoice line** (`invoice_items.id`, e.g. “Line #47”) **or** **invoice** id — backend resolves both.

### Success vs error

- **Success:** HTTP **200**, header **`Content-Type: application/pdf`**, body is **binary** (starts with bytes `%PDF`).
- **Error:** Often **401 / 404 / 500** with **JSON** (`status`, `message`, `data`). Do **not** parse success body as JSON.

### Flutter — download bytes (example pattern)

Use `dio` or `http` with **`ResponseType.bytes`** (Dio) or read `response.bodyBytes` (http). Then:

- write to `getTemporaryDirectory()` / app documents, **or**
- open with `open_file` / `pdfx` / `printing` — **or**
- pass file path to share (see section 3).

Do **not** use `response.data` as `Map` when status is 200 and content-type is PDF.

---

## 2. API — transport shipments (transport user only)

**Auth:** `userTypeVerify:transport` + same `token` header.

| Action | Method | Path |
|--------|--------|------|
| Invoice PDF | `GET` | `/shipments/{id}/download-invoice` |
| Delivery label PDF | `GET` | `/shipments/{id}/download-delivery-label` |

`{id}` = **`shipments.id`**. Only the shipment **owner** (`shipments.user_id`) may download.

---

## 3. `MissingPluginException` — `share_plus` / `share` channel

Error example:

```text
MissingPluginException(No implementation found for method share on channel dev.fluttercommunity.plus/share)
```

This is **not** a Laravel bug. The Flutter engine could not find the **native** implementation of **`share_plus`** in the **current binary** (often **release APK** after a bad build or hot reload).

### Fix checklist (do in order)

1. **Stop the app completely** — do not rely on hot reload / hot restart for new plugins.
2. In project root:
   ```bash
   flutter clean
   flutter pub get
   ```
3. **Android**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   ```
   On Windows PowerShell: `cd android; .\gradlew.bat clean; cd ..`
4. Rebuild a **fresh release APK**:
   ```bash
   flutter build apk --release
   ```
   Install this new APK on the device (uninstall old build if needed).
5. **Version / embedding**
   - Use a **recent** `share_plus` version compatible with your Flutter SDK (`flutter pub outdated`).
   - Ensure `minSdkVersion` in `android/app/build.gradle.kts` (or `.gradle`) meets `share_plus` requirements (often **21+**; some stacks need **23+**).
6. If it **still** fails: create a **new** Flutter project, add only `share_plus` + minimal `Share.shareXFiles` code, build APK — if that works, compare `android/` Gradle settings with your main app.

### Code tip

Call **`Share.shareXFiles`** / **`Share.share`** **after** you have a **real file path** (PDF saved to disk). Sharing invalid or empty paths can cause confusing errors on some devices.

---

## 4. Quick test without `share_plus`

To confirm the **API** works:

1. Download PDF bytes in Flutter and **save to file**.
2. Open with **`open_file`** or show in an in-app **PDF viewer** widget — **no share** — isolate whether the problem is API vs plugin.

---

## 5. Summary (বাংলা সংক্ষেপ)

- API ঠিক আছে; মোবাইলে **`/api/...`** ফুল URL + **`token: Bearer ...`** হেডার দিন।
- সফল হলে রেসপন্স **PDF বাইনারি** — JSON নয়।
- **`MissingPluginException (share)`** মানে **`share_plus` নেটিভ প্লাগইন APK-তে বাঁধা নেই** — `flutter clean`, `gradlew clean`, তারপর **`flutter build apk --release`** দিয়ে নতুন APK ইনস্টল করুন; হট রিলোড যথেষ্ট নয়।

---

## 6. Flutter implementation (this repo — vendor)

Vendor **marketplace** and **walk-in (manual)** order detail screens download via:

| Piece | Location |
|--------|-----------|
| URL builders | `lib/core/constants/api_control/vendor_api.dart` — `vendorAllOrderDownloadInvoice`, `vendorAllOrderDownloadDeliveryLabel` → **`/api/all/order/{id}/…`** (not under `/api/vendor/...`). |
| HTTP + bytes | `lib/features/vendor/.../data/vendor_order_api.dart` — `fetchVendorAllOrderInvoiceDocument`, `fetchVendorAllOrderDeliveryLabelDocument` use **`response.bodyBytes`**, `Accept: application/pdf`, and **`token`** normalized to **`Bearer …`** when the stored token has no `Bearer` prefix. JSON error bodies (starting with `{`) are detected and surfaced as exceptions. |
| Save + share | `lib/features/vendor/.../util/vendor_order_document_local_save.dart` — writes under **`Documents/MarketJango/downloads/`** then **`SharePlus.instance.share`** with a real file path. |

`{id}` is resolved in the UI as **`invoice.orderRecordId` (nested `order.id`) ?? `invoice.id` ?? line `invoiceId`**, matching §1 rules for vendor (invoice or line id).

---

## 7. Flutter implementation (this repo — transport shipments)

Transport **shipment details** downloads via:

| Piece | Location |
|--------|-----------|
| URL builders | `lib/core/constants/api_control/transport_api.dart` — `shipmentDownloadInvoice`, `shipmentDownloadDeliveryLabel` → **`/api/shipments/{id}/…`** (§2). |
| HTTP + bytes | `lib/features/transport/screens/booking_confirm/data/transport_shipment_document_api.dart` — **`response.bodyBytes`**, **`Accept: application/pdf`**, **`token`** normalized to **`Bearer …`** when the stored token has no `Bearer` prefix. JSON error bodies (starting with `{`) are rejected. |
| Save + share | Same as vendor: `lib/features/vendor/.../util/vendor_order_document_local_save.dart` — **`Documents/MarketJango/downloads/`** then **`SharePlus.instance.share`**. |

`{id}` = **`shipments.id`** from the loaded shipment map.
