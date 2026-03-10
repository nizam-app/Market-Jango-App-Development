# Flutter integration: Transport Shipment API

This guide is for Flutter developers integrating the **Transport Shipment** flow: find transporter (driver) → add package details → pay. The user must be logged in as **transport** role (`user_type: transport`).

---

## 1. Base URL and auth

- **Base URL:** `https://your-api.com/api` (replace with your backend base URL).
- **Auth:** All shipment endpoints require a valid **JWT** in the request.
- **Role:** The token must belong to a user with `user_type == 'transport'`. Other roles will get a 403.

**Headers for every request:**

```dart
final headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
  // If your backend expects user id in header (e.g. for tokenVerify):
  // 'id': userId.toString(),
};
```

Use the same token/headers you use for other authenticated API calls in your app.

---

## 2. Response envelope

All endpoints return JSON in this shape:

```json
{
  "status": "success" | "failed",
  "message": "string",
  "data": { ... } | null
}
```

**Dart helper:**

```dart
class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic)? fromJsonT) {
    return ApiResponse(
      status: json['status'] as String? ?? 'failed',
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}
```

Check `isSuccess` before using `data`. On `failed`, show `message` to the user.

---

## 3. Endpoints and Dart usage

### 3.1 Get transport types

**GET** `$baseUrl/shipments/transport-types`

Returns the list of shipping types for the “What type of shipping/transport” selector.

**Response (200):**  
`data.items` = list of strings: `["motorcycle", "car", "air", "water"]`

**Example (Dart + http/dio):**

```dart
Future<List<String>> getTransportTypes() async {
  final res = await http.get(
    Uri.parse('$baseUrl/shipments/transport-types'),
    headers: headers,
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);
  final data = json['data'] as Map<String, dynamic>?;
  final items = data?['items'] as List<dynamic>? ?? [];
  return items.map((e) => e.toString()).toList();
}
```

---

### 3.2 Search transporters (list with price)

**GET** `$baseUrl/shipments/search-transporters`

**Query parameters (all optional):**

| Param                 | Type   | Description                                      |
|-----------------------|--------|--------------------------------------------------|
| `transport_type`      | string | `motorcycle`, `car`, `air`, `water`              |
| `origin_address`      | string | “Shipping from” (shipment origin)                |
| `destination_address` | string | “Shipping to” (shipment destination)            |

These params are for the **shipment route**, not driver fields. Drivers only have a general `location`; origin/destination are stored on the shipment when you create it.

**Example URL:**  
`$baseUrl/shipments/search-transporters?transport_type=car&origin_address=Dhaka&destination_address=Chittagong`

**Response (200):**  
`data.items` = list of driver/transporter objects (see below).

**Driver item model (search list):**

```dart
class TransporterItem {
  final int id;
  final String? carName;
  final String? carModel;
  final String? transportType;
  final String? location;
  final String? price;
  final double estimatedPrice;
  final int rating;
  final String? coverImage;
  final TransporterUser? user;

  TransporterItem({
    required this.id,
    this.carName,
    this.carModel,
    this.transportType,
    this.location,
    this.price,
    required this.estimatedPrice,
    this.rating = 0,
    this.coverImage,
    this.user,
  });

  factory TransporterItem.fromJson(Map<String, dynamic> json) {
    return TransporterItem(
      id: (json['id'] as num).toInt(),
      carName: json['car_name'] as String?,
      carModel: json['car_model'] as String?,
      transportType: json['transport_type'] as String?,
      location: json['location'] as String?,
      price: json['price']?.toString(),
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      coverImage: json['cover_image'] as String?,
      user: json['user'] != null ? TransporterUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

class TransporterUser {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? image;

  TransporterUser({required this.id, this.name, this.email, this.phone, this.image});

  factory TransporterUser.fromJson(Map<String, dynamic> json) {
    return TransporterUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
    );
  }
}
```

**Example call:**

```dart
Future<List<TransporterItem>> searchTransporters({
  String? transportType,
  String? originAddress,
  String? destinationAddress,
}) async {
  final queryParams = <String, String>{};
  if (transportType != null && transportType.isNotEmpty) queryParams['transport_type'] = transportType;
  if (originAddress != null && originAddress.isNotEmpty) queryParams['origin_address'] = originAddress;
  if (destinationAddress != null && destinationAddress.isNotEmpty) queryParams['destination_address'] = destinationAddress;

  final uri = Uri.parse('$baseUrl/shipments/search-transporters').replace(queryParameters: queryParams);
  final res = await http.get(uri, headers: headers);
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);

  final data = json['data'] as Map<String, dynamic>?;
  final items = data?['items'] as List<dynamic>? ?? [];
  return items.map((e) => TransporterItem.fromJson(e as Map<String, dynamic>)).toList();
}
```

---

### 3.3 Transporter details (single driver)

**GET** `$baseUrl/shipments/transporters/{id}`

Same shape as one item in the search list, plus `description`. Use for the “details” screen after the user taps a driver.

**Example:**

```dart
Future<TransporterItem> getTransporterDetails(int driverId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/shipments/transporters/$driverId'),
    headers: headers,
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);
  return TransporterItem.fromJson(json['data'] as Map<String, dynamic>);
}
```

(If you need `description` on the details screen, add an optional `description` field to your model and parse it from `data` here.)

---

### 3.4 Create shipment (draft)

**POST** `$baseUrl/shipments`  
**Body:** JSON (see below).

Creates a shipment in `draft` with packages. After this, call the pay endpoint (e.g. after payment gateway success).

**Request body model:**

```dart
class CreateShipmentRequest {
  final int driverId;
  final String? transportType;
  final String originAddress;
  final String destinationAddress;
  final double? originLatitude;
  final double? originLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? pickupInstructions;
  final String? pickupContactPhone;
  final double? declaredValue;
  final String? declaredValueCurrency;
  final String? messageToDriver;
  final List<ShipmentPackageInput> packages;

  CreateShipmentRequest({
    required this.driverId,
    this.transportType,
    required this.originAddress,
    required this.destinationAddress,
    this.originLatitude,
    this.originLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.pickupInstructions,
    this.pickupContactPhone,
    this.declaredValue,
    this.declaredValueCurrency,
    this.messageToDriver,
    required this.packages,
  });

  Map<String, dynamic> toJson() => {
    'driver_id': driverId,
    if (transportType != null) 'transport_type': transportType,
    'origin_address': originAddress,
    'destination_address': destinationAddress,
    if (originLatitude != null) 'origin_latitude': originLatitude,
    if (originLongitude != null) 'origin_longitude': originLongitude,
    if (destinationLatitude != null) 'destination_latitude': destinationLatitude,
    if (destinationLongitude != null) 'destination_longitude': destinationLongitude,
    if (pickupInstructions != null) 'pickup_instructions': pickupInstructions,
    if (pickupContactPhone != null) 'pickup_contact_phone': pickupContactPhone,
    if (declaredValue != null) 'declared_value': declaredValue,
    if (declaredValueCurrency != null) 'declared_value_currency': declaredValueCurrency,
    if (messageToDriver != null) 'message_to_driver': messageToDriver,
    'packages': packages.map((e) => e.toJson()).toList(),
  };
}

class ShipmentPackageInput {
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? weightKg;
  final int quantity;

  ShipmentPackageInput({
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightKg,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    if (lengthCm != null) 'length_cm': lengthCm,
    if (widthCm != null) 'width_cm': widthCm,
    if (heightCm != null) 'height_cm': heightCm,
    if (weightKg != null) 'weight_kg': weightKg,
    'quantity': quantity,
  };
}
```

**Example call:**

```dart
Future<CreateShipmentResult> createShipment(CreateShipmentRequest request) async {
  final res = await http.post(
    Uri.parse('$baseUrl/shipments'),
    headers: headers,
    body: jsonEncode(request.toJson()),
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);

  final data = json['data'] as Map<String, dynamic>? ?? {};
  return CreateShipmentResult(
    shipment: data['shipment'] as Map<String, dynamic>?,
    totalPieces: (data['total_pieces'] as num?)?.toInt() ?? 0,
    totalWeightKg: (data['total_weight_kg'] as num?)?.toDouble() ?? 0,
  );
}

class CreateShipmentResult {
  final Map<String, dynamic>? shipment;
  final int totalPieces;
  final double totalWeightKg;
  CreateShipmentResult({this.shipment, required this.totalPieces, required this.totalWeightKg});
}
```

Use `shipment['id']` for the pay and detail endpoints.

---

### 3.5 Initiate payment (real payment – use this for the Pay button)

**POST** `$baseUrl/shipments/{id}/initiate-payment`

**This is the API that completes payment.** Call it when the user taps Pay. The backend starts a Flutterwave payment and returns a **payment_url**. Open that URL in a WebView; after the user pays, Flutterwave redirects to the backend, which marks the shipment as paid. No need to call `/pay` when using this flow.

**Example:**

```dart
Future<String?> initiateShipmentPayment(int shipmentId) async {
  final res = await http.post(
    Uri.parse('$baseUrl/shipments/$shipmentId/initiate-payment'),
    headers: headers,
    body: jsonEncode({}),
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);
  final data = json['data'] as Map<String, dynamic>? ?? {};
  return data['payment_url'] as String?;
}
// Usage: open the returned URL in WebView. When user finishes, backend has already marked shipment paid via callback.
```

**Flow:** Create shipment → user taps Pay → call `initiate-payment` → open `payment_url` in WebView → user pays on Flutterwave → Flutterwave redirects to backend callback → shipment is set to paid. Optionally deep-link the user back to your app from the callback page.

---

### 3.5b Mark as paid only (no gateway)

**POST** `$baseUrl/shipments/{id}/pay`  
**Body (optional):** `{ "transaction_id": "gateway_txn_123" }`

Use when you are **not** using the initiate-payment flow (e.g. cash, or you already have a transaction_id from another gateway). Only records the shipment as paid; does not charge a card.

**Where does `transaction_id` come from?**

- **Optional:** You can call this API with an empty body `{}` and the backend still marks the shipment as paid. Use this for “mark as paid” or cash flow without a gateway.
- **When using a payment gateway (e.g. Flutterwave):** The gateway returns a **transaction ID** after the user pays. The Flutter app gets it in one of these ways:
  1. **Redirect URL:** Configure the gateway’s redirect URL to a page that then opens your app (e.g. `myapp://payment-done?transaction_id=12345`). In Flutter, use a deep-link handler or `AppLinks` to read `transaction_id` from the query string and then call `POST .../pay` with it.
  2. **Gateway SDK:** If you use the gateway’s SDK (e.g. Flutterwave SDK), the success callback often returns a result object that includes `transaction_id` or `id`. Read it from that object and send it in the pay request.
  3. **Verify API:** Some gateways let you verify a payment by `tx_ref` and return the `transaction_id`. Your app could call the backend (or the gateway’s verify endpoint), get the transaction id, then call `POST .../pay` with it.

So: **transaction_id** is whatever the payment gateway gives you after a successful payment (redirect query param, SDK callback, or verify response). Pass it in the body so the backend can store it on the shipment; if you don’t have one, omit it or send `{}`.

**Example:**

```dart
Future<void> payShipment(int shipmentId, {String? transactionId}) async {
  final body = transactionId != null ? {'transaction_id': transactionId} : <String, dynamic>{};
  final res = await http.post(
    Uri.parse('$baseUrl/shipments/$shipmentId/pay'),
    headers: headers,
    body: jsonEncode(body),
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);
}
```

---

### 3.6 List my shipments

**GET** `$baseUrl/shipments?per_page=15&page=1`

Returns the current transport user’s shipments (paginated).

**Response:**  
`data.items` = list of shipment summaries; `data.pagination` = `{ total, per_page, current_page, last_page }`.

**Example:**

```dart
Future<ShipmentListResult> getMyShipments({int page = 1, int perPage = 15}) async {
  final uri = Uri.parse('$baseUrl/shipments').replace(queryParameters: {
    'page': page.toString(),
    'per_page': perPage.toString(),
  });
  final res = await http.get(uri, headers: headers);
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);

  final data = json['data'] as Map<String, dynamic>? ?? {};
  final items = (data['items'] as List<dynamic>?) ?? [];
  final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

  return ShipmentListResult(
    items: items.map((e) => e as Map<String, dynamic>).toList(),
    total: (pagination['total'] as num?)?.toInt() ?? 0,
    perPage: (pagination['per_page'] as num?)?.toInt() ?? 15,
    currentPage: (pagination['current_page'] as num?)?.toInt() ?? 1,
    lastPage: (pagination['last_page'] as num?)?.toInt() ?? 1,
  );
}
```

You can parse each item into a small `ShipmentListItem` model with `id`, `origin_address`, `destination_address`, `status`, `payment_status`, `estimated_price`, `final_price`, `total_pieces`, `total_weight_kg`, `driver`, `created_at`, etc.

---

### 3.7 Shipment details (single)

**GET** `$baseUrl/shipments/{id}`

Returns one shipment with full `shipment` object (including `packages`), plus `total_pieces` and `total_weight_kg`. Use for tracking or detail screen.

**Example:**

```dart
Future<Map<String, dynamic>> getShipmentDetails(int shipmentId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/shipments/$shipmentId'),
    headers: headers,
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);
  return json['data'] as Map<String, dynamic>? ?? {};
}
```

---

## 4. Suggested UI flow

1. **Transport types** → Call `getTransportTypes()`, show chips or dropdown (motorcycle, car, air, water).
2. **Origin / destination** → User enters “Shipping from” and “Shipping to”; store as strings.
3. **Search** → Call `searchTransporters(transportType: selectedType, originAddress: origin, destinationAddress: destination)`; show list with price and “Details”.
4. **Details** → On tap, call `getTransporterDetails(driverId)` and show full driver info.
5. **Create shipment** → User picks driver, adds packages (length, width, height, weight, quantity), pickup instructions, declared value, message. Call `createShipment(...)`.
6. **Pay** → After payment (e.g. gateway callback), call `payShipment(shipmentId, transactionId: txnId)`.
7. **My shipments** → List screen uses `getMyShipments(page: page)`; detail/tracking uses `getShipmentDetails(shipmentId)`.

---

## 5. Troubleshooting: Payment success but app not going back

**Problem:** After successful payment, the WebView shows "Webpage not available" or the app doesn’t return to the success screen.

**1. Backend 500 on callback**  
If the callback request to your backend returns **500**, the backend may have been treating a **shipment** `tx_ref` as an invoice. The backend is now updated so that when the callback hits `/api/payment/response` with a `tx_ref` that starts with `shipment_`, it still updates the shipment as paid. Deploy the latest backend so the callback returns 200 and the shipment is marked paid.

**2. `net::ERR_CLEARTEXT_NOT_PERMITTED` in WebView**  
Android 9+ blocks **HTTP** (cleartext) in WebViews by default. The payment/callback URL must be **HTTPS** when opened in the app.

- **Recommended:** Use **HTTPS** for your API base URL (e.g. `https://103.208.183.250` or a domain with SSL). Then `payment_url` and the redirect URL will be HTTPS and the WebView will load.
- **Dev only:** If you must use HTTP, allow cleartext for your backend host in Android:
  - Add `android:usesCleartextTraffic="true"` in `AndroidManifest.xml` under `<application>`, or
  - Use a [network security config](https://developer.android.com/training/articles/security-config#CleartextTrafficPermitted) that allows cleartext only for your backend host.

After fixing the callback (backend 200) and using HTTPS (or cleartext in dev), the redirect page should load and you can close the WebView or deep-link the user back to the app and show the success screen.

---

## 6. Error handling

- **401:** Token missing or invalid → redirect to login.
- **403:** User is not transport role → show “Access denied”.
- **422:** Validation error (e.g. invalid body) → `data` may contain validation errors; show `message` or field errors.
- **404:** Shipment or transporter not found → show `message`.
- **500:** Server error → show generic message and optionally `message` from response.

Always check `status == 'success'` before using `data`. Show `message` when `status == 'failed'`.

---

## 7. Backend reference

- API contract and database summary: [TRANSPORT_SHIPMENT_API.md](./TRANSPORT_SHIPMENT_API.md) in this repo.
