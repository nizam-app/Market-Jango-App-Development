# Vendor order management (time range) + own orders + billing

**বাংলা সারাংশ:** এই ডকুমেন্টে বর্ণনা করা হয়েছে—ভেন্ডারের জন্য অর্ডার লিস্ট (তারিখ রেঞ্জসহ), নিজের তৈরি ম্যানুয়াল/ওয়াক-ইন অর্ডার, স্ট্যাটাস আপডেট, ড্রাইভার পেমেন্ট ইনভয়েস, এবং ওয়ালেট/আয়-সংক্রান্ত API গুলো কোথায় এবং কীভাবে কাজ করে।

**English summary:** APIs that support vendor order listing with optional **date range** filters, **manual (walk-in) orders** the vendor creates, **order item lifecycle** (status transitions), **driver-related invoice / payment initiation**, and **wallet / revenue-style** endpoints.

**ড্রাইভারের জন্য কি একই ডক?** না। নিচের এন্ডপয়েন্টগুলো **`user_type: vendor`** এবং ভেন্ডার ডোমেইন (ম্যানুয়াল অর্ডার, লাইন আইটেম `vendor_id`)—ড্রাইভার আলাদা রুট (`/api/driver/...`, লিগাসি `/api/all-order/driver`) ব্যবহার করে। ড্রাইভারের **ডেলিভারি লিস্টে** বর্তমান কোডে **`from_date` / `to_date` ফিল্টার নেই** (শুধু `status` যেখানে প্রযোজ্য)।

**Same doc for drivers?** No. This file documents **vendor** APIs. Drivers use **different** routes; see §9 below.

---

## Base path and authentication

- **API prefix:** all routes below are under `/api` (Laravel default `routes/api.php`).
- **Middleware (vendor order routes):** `tokenVerify` + `userTypeVerify:vendor` + `statusVerify` (active vendor account).
- **Headers:** The app typically sends the same headers as other authenticated calls, including at least:
  - `Authorization: Bearer <token>`
  - `id` — logged-in user’s numeric ID (must match the vendor’s `user_id`)
  - `user_type: vendor`
  - `email` — required for some legacy flows (e.g. driver invoice creation)

---

## 1. Order list with time range (recommended)

These are the **primary** endpoints for filtered vendor order management. They return **paginated** results and support **`from_date` / `to_date`** (inclusive, `Y-m-d`).

### 1.1 `GET /api/vendor/orders`

**Purpose:** List **invoice line items** (`invoice_items`) that belong to the logged-in vendor—i.e. marketplace orders where this vendor has products.

**Query parameters (all optional):**

| Parameter      | Type   | Description |
|----------------|--------|-------------|
| `from_date`    | date   | `invoice_items.created_at` ≥ this day |
| `to_date`      | date   | `invoice_items.created_at` ≤ this day |
| `order_number` | string | Partial match on parent `invoice.order_number` |
| `status`       | string | Exact match on `invoice_items.status` (see §5) |
| `per_page`     | int    | Page size, default `10` |

**Includes:** `invoice` (order number, status, payment method, dates), `product`, assigned `driver` + `driver.user`.

**Implementation reference:** `App\Http\Controllers\Api\VendorOrderController@index`

### 1.2 `GET /api/vendor/manual-orders`

**Purpose:** List **manual / walk-in orders** the vendor created. Each row is one **`Invoice`** with `is_manual_order = true`; nested `items` are this vendor’s lines only.

**Query parameters (all optional):**

| Parameter      | Type   | Description |
|----------------|--------|-------------|
| `from_date`    | date   | Invoice `created_at` ≥ this day |
| `to_date`      | date   | Invoice `created_at` ≤ this day |
| `order_number` | string | Partial match on `order_number` |
| `status`       | string | Invoice is included if **at least one** line item has this status |
| `per_page`     | int    | Default `10` |

Each invoice in the list gets a computed **`summary`**: `total`, `payable`, `customer_paid`, `change` (cash change when `customer_paid` is set).

**Implementation reference:** `App\Http\Controllers\Api\VendorManualOrderController@index`

---

## 2. Vendor creates their own order (manual / walk-in)

### 2.1 `POST /api/vendor/manual-orders`

**Purpose:** Create a new manual order (customer at counter / phone order). Creates an `Invoice` owned by the vendor user (`user_id` = vendor’s user id) and `invoice_items` for that vendor’s products; reduces **stock**.

**Body (JSON):**

| Field             | Required | Notes |
|-------------------|----------|--------|
| `customer_name`   | yes      | max 100 |
| `customer_phone`  | no       | max 30 |
| `payment_method`  | yes      | `Cash`, `Card`, or `Mobile` |
| `customer_paid`   | no       | Cash tendered; backend can compute change |
| `items`           | yes      | min 1 |
| `items[].product_id` | yes   | must belong to this vendor |
| `items[].quantity`   | yes   | min 1, stock checked |

**Response:** `invoice`, `items`, and `summary` (`total`, `vat`, `payable`, `customer_paid`, `change`). Manual orders use **VAT 0** by default.

**Implementation reference:** `VendorManualOrderController@create`

### 2.2 Edit manual order (while pending)

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/api/vendor/manual-orders/{id}/items` | Add line or merge quantity for same product (`product_id`, `quantity`) |
| `DELETE` | `/api/vendor/manual-orders/{id}/items/{item_id}` | Remove a line; stock restored |

Only allowed while items are in **pending** (see controller validation).

### 2.3 `POST /api/vendor/manual-orders/{id}/deliver`

**Purpose:** Mark all lines **delivered** (e.g. customer picked up). Optional body: `customer_paid`, `note`.

**Implementation reference:** `VendorManualOrderController@deliver`

### 2.4 `GET /api/vendor/manual-orders/{id}`

**Purpose:** Single manual order detail (`id` = **invoice id**). Includes live `summary` from current items.

---

## 3. Single marketplace order line + status changes

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/api/vendor/orders/{id}` | One `invoice_item` by id (must belong to vendor); includes `allowed_next_statuses` |
| `PUT` | `/api/vendor/orders/{id}/status` | Body: `status` (required), `note` (optional). Uses `OrderStatusService` transition rules |
| `GET` | `/api/vendor/orders/statuses` | Lists valid statuses and the **transition matrix** for UI dropdowns |

**Implementation reference:** `VendorOrderController`

---

## 4. Legacy / related vendor order endpoints

### 4.1 `GET /api/vendor/all/order`

**Purpose:** Returns **all** `InvoiceItem` rows for the vendor in one response (**no pagination**, **no date filter** in code). Prefer **`GET /api/vendor/orders`** for production UIs that need filters and pages.

**Implementation reference:** `VendorHomePageController@vendorAllOrder`

### 4.2 `POST /api/vendor/invoice/create/{driver_id}/{order_item_id}`

**Purpose:** Legacy **driver payment / Flutterwave** flow: creates a **new** `Invoice` for delivery charge linked to the given **order item** and driver, then returns payment initiation payload from `PaymentSystem::InitiatePayment`.

**Note:** This is **not** the same as buyer checkout; it is vendor-initiated payment for a driver charge on a specific line item.

**Implementation reference:** `VendorHomePageController@vendorInvoice`

---

## 5. Order status values (filter / transitions)

Use lowercase strings consistent with `App\Enums\OrderStatus`:

`pending`, `processing`, `completed`, `assigned`, `delivered`, `cancelled`, `returned`

Allowed transitions are defined in `OrderStatus::TRANSITIONS` and enforced in `OrderStatusService`.

---

## 6. Admin: all orders with filters (cross-vendor)

**`GET /api/all/order`** (admin only, `userTypeVerify:admin`)

**Query parameters (optional):** `from_date`, `to_date`, `order_number`, `status`, `vendor_id`, `zone_id`, `per_page`.

Filters apply to **`invoice_items`** (date uses `invoice_items.created_at`).

**Implementation reference:** `AdminController@allOrder`

---

## 7. Billing-adjacent APIs (vendor)

### 7.1 Manual order totals

Manual order **list/detail** responses include **`summary`** fields: subtotal/payable, optional `customer_paid` and **change**—suitable for a POS-style billing screen.

### 7.2 Wallet (vendor)

Under the same vendor middleware group:

| Method | Path | Notes |
|--------|------|--------|
| `GET` | `/api/vendor/wallet` | Balance + summary |
| `GET` | `/api/vendor/wallet/transactions` | Paginated history; supports `from_date`, `to_date`, `type`, `status` |
| `POST` | `/api/vendor/wallet/payout` | Payout request |
| `GET` | `/api/vendor/wallet/payouts` | Vendor’s payout requests |

**Implementation reference:** `WalletController`

### 7.3 Income / analytics (legacy vendor home)

| Method | Path | Notes |
|--------|------|--------|
| `GET` | `/api/vendor/income` | Sums `sale_price` for items with status `Complete` (legacy string; may differ from enum `completed`) |
| `GET` | `/api/vendor/income/update?days=30` | Revenue and order count in last **N** days; not arbitrary `from`/`to` in query |

**Implementation reference:** `VendorHomePageController`

---

## 8. Quick reference table

| Need | Endpoint |
|------|----------|
| Marketplace orders + **date range** | `GET /api/vendor/orders` |
| Manual orders + **date range** | `GET /api/vendor/manual-orders` |
| Create vendor’s own order | `POST /api/vendor/manual-orders` |
| Manual order detail / deliver | `GET/POST /api/vendor/manual-orders/{id}…` |
| Update line status (marketplace) | `PUT /api/vendor/orders/{id}/status` |
| Driver charge payment invoice | `POST /api/vendor/invoice/create/{driver_id}/{order_item_id}` |
| Wallet + tx with date filter | `GET /api/vendor/wallet`, `GET /api/vendor/wallet/transactions` |
| Admin global order list + filters | `GET /api/all/order` |

---

## 9. Driver: related but not the same as vendor order management

Drivers do **not** call `/api/vendor/orders` or `/api/vendor/manual-orders`. Typical driver flows in this codebase:

| Need | Endpoint | Notes |
|------|----------|--------|
| Assigned deliveries (modern) | `GET /api/driver/deliveries` | `DriverAssignment` list; optional `status` query; **no** `from_date`/`to_date` in `DriverDeliveryController@index` |
| Assignment detail + actions | `GET /api/driver/deliveries/{id}`, `POST .../accept`, `reject`, `pickup`, `deliver`, `location` | Under `userTypeVerify:driver` + prefix `driver` |
| Legacy: all items linked to driver | `GET /api/all-order/driver` | `InvoiceItem` where `driver_id` = this driver; **no** date filter, not paginated (`DriverHomeController@allOrdersDriver`) |
| Legacy: “new” orders | `GET /api/new-order/driver` | Filters `status = AssignedOrder` (legacy string; may not match `OrderStatus` enum values) |
| Wallet / transactions (date filter on tx) | `GET /api/driver/wallet`, `GET /api/driver/wallet/transactions` | Same `WalletController` pattern as vendor; `transactions` supports `from_date` / `to_date` |
| Home-style stats | `GET /api/driver/home-stats` | Counts / summaries (legacy status strings in parts of `DriverHomeController`) |

**Billing:** Drivers do not create **manual POS orders** like vendors. Earnings/wallet behavior is via **wallet** and assignment/delivery completion logic, not vendor manual-order `summary` fields.

---

## Related docs

- Buyer checkout / invoice: [FLUTTER_INVOICE_CREATE.md](./FLUTTER_INVOICE_CREATE.md)
