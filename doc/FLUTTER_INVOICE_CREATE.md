# Flutter: How to Create an Invoice (Buyer Order Flow)

This guide explains how a **Flutter developer** implements the buyer flow: **cart → create invoice → pay (online or cash)** using this Laravel API.

---

## 1. Prerequisites

- **Auth:** User must be logged in and send the JWT on every request (e.g. `Authorization: Bearer <token>`). The backend also expects `id` and `email` in headers (from your token payload or auth middleware).
- **Role:** The user must have a **Buyer** profile. Invoice creation uses the buyer’s **shipping address** from the Buyer record (`ship_latitude`, `ship_longitude`, `ship_location`). Ensure the buyer has set a delivery address before creating an invoice.
- **Cart:** The buyer must have at least one **active** cart item. Invoice is created from the current active cart.

---

## 2. Flow Overview

```
1. Add items to cart     → POST /api/cart/create
2. (Optional) Get cart   → GET  /api/cart
3. Create invoice        → POST /api/invoice/create  (body: payment_method)
4a. If online payment    → Open payment_url in WebView → User pays → Backend callback updates invoice
4b. If cash (OPU)        → Backend returns success; no payment URL
5. List orders / track   → GET /api/buyer/all-order, GET /api/buyer/invoice/tracking/details/{id}
```

---

## 3. Step-by-Step for Flutter

### 3.1 Add to cart (if not already done)

**POST** `$baseUrl/cart/create`

**Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, and whatever your backend expects (e.g. `id`, `email`).

**Body (JSON):**
```json
{
  "product_id": 123,
  "quantity": 2,
  "attributes": null,
  "action": null
}
```

- `product_id` (required): product ID.
- `quantity` (optional, default 1): quantity to add.
- `attributes` (optional): JSON string for product attributes.
- `action` (optional): `"increase"` or `"decrease"` when updating an existing cart line.

**Response (200):** Cart item with `price`, `delivery_charge`, `quantity`, `product_id`, `vendor_id`, etc. The backend calculates `price` and `delivery_charge` from product and buyer/vendor location.

**Dart example:**
```dart
Future<void> addToCart(int productId, {int quantity = 1}) async {
  final res = await http.post(
    Uri.parse('$baseUrl/cart/create'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'id': userId.toString(),
      'email': userEmail,
    },
    body: jsonEncode({
      'product_id': productId,
      'quantity': quantity,
    }),
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);
}
```

---

### 3.2 Get cart (optional)

**GET** `$baseUrl/cart`

Returns the buyer’s active cart items and total. Use this to show the checkout screen (items, total, delivery charges).

**Response (200):**  
`data` is an array: first element is list of cart items, second is a map with `"total"` (sum of price + delivery_charge).

---

### 3.3 Create invoice (order)

**POST** `$baseUrl/invoice/create`

This creates the **invoice (order)** from the current **active** cart. No cart item IDs in the body: the backend uses all active cart items for the logged-in buyer.

**Headers:** Same as above (Bearer token, `id`, `email`).

**Body (JSON):**
```json
{
  "payment_method": "OPU"
}
```

- **`payment_method`** (required):
  - **`"OPU"`** = Cash on delivery (or similar). Backend creates the invoice and returns success **without** a payment URL. No WebView.
  - **Any other value** (e.g. `"card"`, `"online"`): Backend creates the invoice and initiates **Flutterwave** payment. Response includes a **`payment_url`** that you must open in a browser/WebView so the user can pay.

**Response (200) – Cash (OPU):**
```json
{
  "status": "success",
  "message": "Order placed with Cash On Delivery",
  "data": {
    "paymentMethod": { ... invoice object ... },
    "payable": 150.00,
    "vat": 0,
    "total": 150.00
  }
}
```

**Response (200) – Online payment:**
```json
{
  "status": "success",
  "message": "Order placed with Online payment",
  "data": {
    "paymentMethod": {
      "payment_url": "https://checkout.flutterwave.com/...",
      "status": "success"
    },
    "payable": 150.00,
    "vat": 0,
    "total": 150.00
  }
}
```

**Dart example – create invoice and handle payment method:**
```dart
Future<void> createInvoice({required bool isCashOnDelivery}) async {
  final res = await http.post(
    Uri.parse('$baseUrl/invoice/create'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'id': userId.toString(),
      'email': userEmail,
    },
    body: jsonEncode({
      'payment_method': isCashOnDelivery ? 'OPU' : 'card',
    }),
  );
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  if (json['status'] != 'success') throw Exception(json['message']);

  final data = json['data'] as Map<String, dynamic>? ?? {};
  final total = (data['total'] as num?)?.toDouble();
  final payable = (data['payable'] as num?)?.toDouble();
  final paymentMethod = data['paymentMethod'];

  if (paymentMethod is Map<String, dynamic>) {
    final paymentUrl = paymentMethod['payment_url'] as String?;
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      // Open WebView or browser so user can pay
      await openPaymentWebView(paymentUrl);
      // After user returns to app, refresh order list or track by invoice id
    }
  }
  // If OPU, no payment URL; order is placed. Show success and go to order list.
}
```

---

### 3.4 After online payment (payment URL)

1. Open `data.paymentMethod.payment_url` in an in-app WebView or browser.
2. User completes payment on Flutterwave’s page.
3. Flutterwave redirects to the **backend** URL: **GET** `$baseUrl/payment/response?transaction_id=...&tx_ref=...&status=...`. The backend updates the invoice status (e.g. `successful`, `failed`). **You do not call this URL from Flutter**; the redirect is from Flutterwave.
4. To bring the user back to your app after payment, either:
   - Use a **custom redirect URL** (if your backend supports it) that points to a page that redirects to your app (e.g. `myapp://payment-done?tx_ref=...`), or
   - Use a **WebView** and listen for redirect URL / navigation to a “success” or “failure” page that you control and then close the WebView and refresh the order list.

After the user returns to the app, refresh the order list or fetch invoice details (see below). The backend will have updated the invoice status when it received the callback.

---

### 3.5 Get buyer’s orders (order list)

**GET** `$baseUrl/buyer/all-order`

Returns all order items for the logged-in buyer (invoice items with product and invoice).

**Response (200):**  
`data.data` = list of invoice items (each has `invoice`, `product`, etc.).

---

### 3.6 Get invoice / tracking details

**GET** `$baseUrl/buyer/invoice/tracking/details/{invoice_id}`

Returns one invoice with status history (`statusLogs`). Use for “track order” or order detail screen.

**Response (200):** Invoice object with `statusLogs` and related data.

---

## 4. Error handling

- **404 "User not found"** → User not logged in or invalid token / headers.
- **404 "Buyer not found"** → User has no Buyer profile; ensure they completed buyer registration and have a delivery address.
- **404 "Cart not found"** → No active cart items; add products to cart first.
- **400 "Not enough stock for product ID ..."** → Reduce quantity or remove that product from cart.
- **422** → Validation error; check `data` for field errors.

Always check `status == 'success'` before using `data`. Show `message` when `status == 'failed'`.

---

## 5. Summary: “How does the Flutter developer create an invoice?”

1. Ensure the user is a **buyer** with a **delivery address** set (backend reads it from Buyer profile).
2. Ensure the buyer has **active cart items** (add via `POST /api/cart/create`).
3. Call **POST** **`/api/invoice/create`** with body `{ "payment_method": "OPU" }` for cash, or another value (e.g. `"card"`) for online payment.
4. If the response contains **`data.paymentMethod.payment_url`**, open it in a WebView/browser so the user can pay; then handle return to app and refresh orders.
5. Use **GET** **`/api/buyer/all-order`** and **GET** **`/api/buyer/invoice/tracking/details/{invoice_id}`** to show order list and tracking.

The **invoice is created by the backend** when you call **POST `/api/invoice/create`**. There is no separate “create invoice” and “pay” call for the initial order: one call creates the invoice and, for online payment, returns the URL to collect payment.
