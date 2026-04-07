# Flutter API reference by role (Buyer, Vendor, Driver, Transport)

This document lists **API endpoints** from `routes/api.php` that match your product requirements, grouped by **user role**. Use it to wire a Flutter app: same **base URL** + `/api` prefix for every path below.

**Base:** `{BASE_URL}/api`  
Example: `https://your-domain.com/api/vendor/orders`

---

## Common headers (all authenticated routes)

Routes inside `Route::middleware(['tokenVerify'])->group(...)` expect a valid token. The codebase also uses header **`id`** (numeric user id) widely; many flows expect **`email`** and **`user_type`** as well.

| Header | Typical use |
|--------|-------------|
| `Authorization` | `Bearer <JWT or token from your login response>` |
| `id` | Logged-in user’s `users.id` |
| `email` | User email (checkout, some invoices) |
| `user_type` | `buyer` \| `vendor` \| `driver` \| `transport` \| `admin` — must match route middleware |

**Role-specific routes** additionally use `userTypeVerify:<role>` — send the correct `user_type` or the server returns 403.

---

## 1. Buyer (`user_type: buyer`)

Middleware: `userTypeVerify:buyer` where noted. Many **order / invoice** routes are in the shared `tokenVerify` group (any logged-in user) but are **used by buyers** in practice.

### 1.1 Order management

| Feature | Method | Path | Notes |
|--------|--------|------|--------|
| Create invoice from cart | `POST` | `/invoice/create` | Body includes `payment_method`; see [FLUTTER_INVOICE_CREATE.md](./FLUTTER_INVOICE_CREATE.md) |
| List buyer orders | `GET` | `/buyer/all-order` | |
| List invoices (generic) | `GET` | `/invoice` | |
| Invoice line items | `GET` | `/InvoiceProductList/{invoice_id}` | |
| Payment verify | `GET` | `/payment/verify` | |
| Tracking detail | `GET` | `/buyer/invoice/tracking/details/{id}` | |
| **Live tracking** | `GET` | `/buyer/orders/{order_id}/track` | |
| **Tracking path** | `GET` | `/buyer/orders/{order_id}/track/path` | |

### 1.2 Cart & checkout (buyer-only)

| Method | Path |
|--------|------|
| `GET` | `/cart` |
| `POST` | `/cart/create` |
| `DELETE` | `/cart/{id}` |
| `POST` | `/cart/checkout` |
| `POST` | `/cart/offer/{offerId}/add` |

### 1.3 Wallet & refund

| Feature | Method | Path | Notes |
|--------|--------|------|--------|
| Wallet balance / summary | `GET` | `/wallet` | No `/buyer` prefix |
| Transactions (optional `from_date`, `to_date`, `type`, `status`) | `GET` | `/wallet/transactions` | |
| Top-up | `POST` | `/wallet/topup` | Body: `amount`, optional `note` |
| Payout request | `POST` | `/wallet/payout` | Body: `amount`, `payment_method`, `payment_details`, optional `note` |
| My payouts | `GET` | `/wallet/payouts` | Optional `status` query |
| List refunds | `GET` | `/buyer/refunds` | |
| Refund detail | `GET` | `/buyer/refunds/{id}` | |
| Request refund (order line) | `POST` | `/buyer/orders/{item_id}/refund` | `item_id` = invoice item id |

### 1.4 Other buyer-only (useful for app)

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/wish-list` | |
| `POST` | `/wish-list/create-update` | |
| `POST` | `/wish-list/destroy/{wishlist_id}` | |
| `GET` | `/review` | |
| `POST` | `/review/destroy/{review_id}` | |

**Deep dives:** [FLUTTER_INVOICE_CREATE.md](./FLUTTER_INVOICE_CREATE.md)

---

## 2. Vendor (`user_type: vendor`)

Middleware: `userTypeVerify:vendor` + **`statusVerify`** on most business routes (account must be active).

### 2.1 Order management + time range + own (manual) orders + billing-related

| Feature | Method | Path | Query / notes |
|--------|--------|------|----------------|
| Valid statuses / transitions | `GET` | `/vendor/orders/statuses` | |
| **Orders list (date range)** | `GET` | `/vendor/orders` | `from_date`, `to_date`, `order_number`, `status`, `per_page` |
| Order line detail | `GET` | `/vendor/orders/{id}` | |
| Update line status | `PUT` | `/vendor/orders/{id}/status` | JSON: `status`, optional `note` |
| **Manual orders list (date range)** | `GET` | `/vendor/manual-orders` | `from_date`, `to_date`, `order_number`, `status`, `per_page` |
| Create walk-in / phone order | `POST` | `/vendor/manual-orders` | Customer + `items[]` |
| Manual order detail | `GET` | `/vendor/manual-orders/{id}` | `id` = invoice id |
| Add line to manual order | `POST` | `/vendor/manual-orders/{id}/items` | |
| Remove line | `DELETE` | `/vendor/manual-orders/{id}/items/{item_id}` | |
| Mark manual order delivered | `POST` | `/vendor/manual-orders/{id}/deliver` | |
| Legacy: all order lines (no filters) | `GET` | `/vendor/all/order` | Prefer `/vendor/orders` |
| Driver charge invoice (Flutterwave) | `POST` | `/vendor/invoice/create/{driver_id}/{order_item_id}` | Legacy payment flow |
| Available drivers | `GET` | `/vendor/drivers/available` | |
| Assign / unassign driver | `POST` | `/vendor/orders/{item_id}/assign-driver`, `/unassign-driver` | |
| Show assignment | `GET` | `/vendor/orders/{item_id}/assignment` | |

**Details:** [VENDOR_ORDER_MANAGEMENT_AND_BILLING.md](./VENDOR_ORDER_MANAGEMENT_AND_BILLING.md)

### 2.2 Barcode & scanner

| Method | Path |
|--------|------|
| `GET` | `/vendor/products/barcodes` |
| `GET` | `/vendor/products/barcode/{code}` |
| `GET` | `/vendor/products/{id}/barcode` |
| `POST` | `/vendor/products/{id}/barcode/regenerate` |
| `POST` | `/vendor/products/{id}/barcode/labels` |

**Details:** [VENDOR_BARCODE_AND_SCANNER_API.md](./VENDOR_BARCODE_AND_SCANNER_API.md)

### 2.3 Wallet & refund

| Feature | Method | Path |
|--------|--------|------|
| Wallet | `GET` | `/vendor/wallet` |
| Transactions | `GET` | `/vendor/wallet/transactions` |
| Payout | `POST` | `/vendor/wallet/payout` |
| Payouts list | `GET` | `/vendor/wallet/payouts` |
| Refunds list / detail | `GET` | `/vendor/refunds`, `/vendor/refunds/{id}` |
| Approve / reject refund | `POST` | `/vendor/refunds/{id}/approve`, `/reject` |
| Vendor-initiated refund request | `POST` | `/vendor/orders/{item_id}/refund` |

### 2.4 Product & “inventory” (stock)

There is **no separate REST module** named “inbound/outbound stock ledger” with time-range filters in this repo. **Stock** is the `products.stock` field, updated when:

- Buyers checkout (`POST /invoice/create`) or manual orders / line edits run.

**Vendor product & catalog APIs (manage stock via product update):**

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/vendor/product` | Paginated products |
| `POST` | `/product/create` | Create product (includes stock) |
| `POST` | `/product/update/{id}` | Update product / stock |
| `POST` | `/product/destroy/{id}` | |
| `GET` | `/vendor/search-by-vendor` | Search own products |

To approximate “outbound by time” in the app, combine **`GET /vendor/orders`** or **`GET /vendor/manual-orders`** (date range + `product` relation) with current **`GET /vendor/product`** for on-hand quantity.

### 2.5 Delivery charge & route points (vendor + admin shared / vendor)

See `delivery-charge` and `vendor/route-points` in `routes/api.php` if your Flutter vendor app includes zone pricing.

---

## 3. Driver (`user_type: driver`)

Prefix **`/driver`** for wallet and deliveries. Other driver routes are **without** that prefix (legacy).

### 3.1 Wallet

| Method | Path | Notes |
|--------|------|--------|
| `GET` | `/driver/wallet` | |
| `GET` | `/driver/wallet/transactions` | Optional `from_date`, `to_date`, `type`, `status` |
| `POST` | `/driver/wallet/payout` | Same payout body rules as `WalletController` |
| `GET` | `/driver/wallet/payouts` | |

**Top-up:** `WalletController::topup` allows only **buyer** and **transport** — drivers use **payout** / earnings, not `topup` on this endpoint.

### 3.2 Refund

**No driver-specific refund list/request endpoints** are registered in `routes/api.php`. Refunds are modeled for **buyer** (request) and **vendor** (approve/reject) plus **admin**. If the product needs “driver refunds”, it would require new APIs or reuse of another role (not present now).

### 3.3 Deliveries & orders (operational)

| Feature | Method | Path |
|--------|--------|------|
| Assignments list | `GET` | `/driver/deliveries` | Optional `status`; paginated |
| Assignment detail | `GET` | `/driver/deliveries/{id}` | |
| Accept / reject | `POST` | `/driver/deliveries/{id}/accept`, `/reject` |
| Pickup / deliver | `POST` | `/driver/deliveries/{id}/pickup`, `/deliver` |
| GPS ping | `POST` | `/driver/deliveries/{id}/location` |
| Home stats | `GET` | `/driver/home-stats` | |
| Legacy: all assigned lines | `GET` | `/all-order/driver` | No date filter in controller |
| Legacy: “new” orders | `GET` | `/new-order/driver` | Uses legacy status string |
| Register driver | `POST` | `/driver/register` | |

### 3.4 Shared (token only) tracking / invoice helpers

Under `tokenVerify` (check server rules for who may call):

| Method | Path |
|--------|------|
| `GET` | `/driver/invoice/pending/tracking/{id}` |
| `GET` | `/driver/invoice/tracking/{id}` |
| `GET` | `/driver/successful/invoice/tracking/{id}` |
| `GET` | `/driver/cancel/invoice/tracking/{id}` |
| `PUT` | `/driver/invoice/update-status/{id}` |

**Details:** [VENDOR_ORDER_MANAGEMENT_AND_BILLING.md](./VENDOR_ORDER_MANAGEMENT_AND_BILLING.md) §9 (driver vs vendor)

---

## 4. Transport (`user_type: transport`)

### 4.1 Wallet

| Method | Path |
|--------|------|
| `GET` | `/transport/wallet` |
| `GET` | `/transport/wallet/transactions` |
| `POST` | `/transport/wallet/topup` |
| `POST` | `/transport/wallet/payout` |
| `GET` | `/transport/wallet/payouts` |

### 4.2 Order / shipment management

| Feature | Method | Path |
|--------|--------|------|
| List transport-related orders | `GET` | `/all-order/transport` | Shared `tokenVerify` group |
| Create invoice / payment for driver | `POST` | `/transport/invoice/create/{driver_id}` | Shared group |
| Tracking | `GET` | `/transport/invoice/tracking/{id}` |
| Success / cancel views | `GET` | `/transport/successful/invoice/details/{id}`, `/transport/cancel/invoice/tracking/{id}` |

### 4.3 Shipments API (transport-only group)

Prefix **`/shipments`** (still under `/api`, inside `userTypeVerify:transport`):

| Method | Path |
|--------|------|
| `GET` | `/shipments/transport-types` |
| `GET` | `/shipments/search-transporters` |
| `GET` | `/shipments/transporters/{id}` |
| `POST` | `/shipments` |
| `POST` | `/shipments/{id}/initiate-payment` |
| `POST` | `/shipments/{id}/pay` |
| `GET` | `/shipments` |
| `GET` | `/shipments/{id}` |

### 4.4 Refund

**No transport-specific buyer-style refund routes** in `routes/api.php`. Use admin/support flows if required, or extend API.

**Related:** [FLUTTER_TRANSPORT_SHIPMENT.md](./FLUTTER_TRANSPORT_SHIPMENT.md), [TRANSPORT_SHIPMENT_API.md](./TRANSPORT_SHIPMENT_API.md)

---

## 5. Requirement checklist vs this backend

| Requirement (from spec) | Buyer | Vendor | Driver | Transport |
|-------------------------|-------|--------|--------|-----------|
| Order management (+ time range where noted) | Cart + `/invoice/create`, `/buyer/all-order`; tracking endpoints | `/vendor/orders`, `/vendor/manual-orders` + filters | `/driver/deliveries` (+ legacy lists; limited date filters) | `/all-order/transport`, `/shipments/*`, transport invoice |
| Barcode / scanner | — | `/vendor/products/barcodes`, scan route, etc. | — | — |
| Wallet | `/wallet/*` | `/vendor/wallet/*` | `/driver/wallet/*` | `/transport/wallet/*` |
| Refunds | `/buyer/refunds/*`, request on order line | `/vendor/refunds/*` | **No dedicated API** | **No dedicated API** |
| Inventory in/out + time + product filter | — | **No dedicated ledger API**; use product `stock` + order APIs | — | — |

---

## 6. Suggested Flutter structure

- One **`ApiClient`** with base URL, token interceptor, and default headers (`id`, `email`, `user_type`).
- Separate service classes per role: `BuyerOrderApi`, `VendorOrderApi`, `DriverDeliveryApi`, `TransportShipmentApi`, each importing only the rows from the tables above.
- Reuse **`WalletService`** pattern per role; paths differ (`/wallet` vs `/vendor/wallet` vs `/driver/wallet` vs `/transport/wallet`).

For Postman-style demos of some modules, see other files under `docs/`.
