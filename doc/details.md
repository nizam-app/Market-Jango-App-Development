# Vendor module — API list & Flutter integration reference

Maps the **Postman “vendor”** collection (orders, manual orders, barcodes, refunds, wallet, driver assignment) to this Laravel backend. Paths use prefix **`/api`**.

---

## Auth & middleware

- Outer: **`tokenVerify`** (header **`token`** = JWT).
- **`userTypeVerify:vendor`**
- Inner group: **`statusVerify`** — vendor account is expected to be in an allowed status (e.g. approved); blocked users may get errors from that middleware.

### Headers

| Header | Value |
|--------|--------|
| `token` | JWT |
| `Accept` | `application/json` |
| `Content-Type` | `application/json` for bodies |

### Response `status` field

Most endpoints use `ResponseHelper` with `status`: **`success`** / **`error`**. Some vendor order/manual-order paths return **`failed`** instead of **`error`** on errors — in Flutter, treat any non-`success` as failure and read `message` / `data`.

---

## Master list — Vendor (Postman mapping)

### Order management

| Postman idea | Method | Path |
|--------------|--------|------|
| List vendor orders with filters | `GET` | `/api/vendor/orders` |
| Valid statuses + transition matrix | `GET` | `/api/vendor/orders/statuses` |
| Single order (item) + allowed next statuses | `GET` | `/api/vendor/orders/{id}` |
| Change order status | `PUT` | `/api/vendor/orders/{id}/status` |

`{id}` = **`invoice_items.id`** (one line item).

### Manual (walk-in) orders

| Postman idea | Method | Path |
|--------------|--------|------|
| List manual orders with filters | `GET` | `/api/vendor/manual-orders` |
| Create manual order | `POST` | `/api/vendor/manual-orders` |
| Manual order detail | `GET` | `/api/vendor/manual-orders/{id}` |
| Add item to pending order | `POST` | `/api/vendor/manual-orders/{id}/items` |
| Remove an item | `DELETE` | `/api/vendor/manual-orders/{id}/items/{item_id}` |
| Mark as delivered (customer picked up) | `POST` | `/api/vendor/manual-orders/{id}/deliver` |

`{id}` for manual flows = **`invoices.id`** where `is_manual_order` is true (vendor’s walk-in invoice).

### Products & barcodes

| Postman idea | Method | Path |
|--------------|--------|------|
| List products + barcodes | `GET` | `/api/vendor/products/barcodes` |
| Scan barcode (camera / scanner) | `GET` | `/api/vendor/products/barcode/{code}` |
| Barcode for one product | `GET` | `/api/vendor/products/{id}/barcode` |
| Regenerate barcode | `POST` | `/api/vendor/products/{id}/barcode/regenerate` |
| Print labels | `POST` | `/api/vendor/products/{id}/barcode/labels` |

`{code}` = raw scanned string (URL-encode if needed).

### Refunds

| Postman idea | Method | Path (this backend) |
|--------------|--------|---------------------|
| Vendor sees pending refunds | `GET` | `/api/vendor/refunds?status=pending` |
| List all refund requests for my store | `GET` | `/api/vendor/refunds` |
| View one refund detail | `GET` | `/api/vendor/refunds/{id}` |
| Vendor initiates refund on behalf of buyer | `POST` | `/api/vendor/orders/{item_id}/refund` |
| Vendor approves refund | `POST` | `/api/vendor/refunds/{id}/approve` |
| Vendor rejects refund | `POST` | `/api/vendor/refunds/{id}/reject` |

**Postman note:** If your collection uses **POST** for “list” or “detail”, align the app with the backend: **list = GET**, **detail = GET**. Use query params on `GET /vendor/refunds` for filters.

### Wallet & payouts (no self top-up)

| Postman idea | Method | Path |
|--------------|--------|------|
| Balance + summary | `GET` | `/api/vendor/wallet` |
| Transaction history | `GET` | `/api/vendor/wallet/transactions` |
| Request withdrawal | `POST` | `/api/vendor/wallet/payout` |
| My payout requests | `GET` | `/api/vendor/wallet/payouts` |

There is **no** `POST /api/vendor/wallet/topup` in this codebase (unlike buyer/transport).

---

## Vendor ▸ Driver (assignment)

| Postman idea | Method | Path |
|--------------|--------|------|
| List available drivers | `GET` | `/api/vendor/drivers/available` |
| Assign driver to order item | `POST` | `/api/vendor/orders/{item_id}/assign-driver` |
| Cancel driver assignment | `POST` | `/api/vendor/orders/{item_id}/unassign-driver` |
| Assignment history for item | `GET` | `/api/vendor/orders/{item_id}/assignment` |

`{item_id}` = **`invoice_items.id`**.

---

## Endpoint details

### `GET /api/vendor/orders`

**Query:** `from_date`, `to_date` (Y-m-d), `order_number` (partial), `status` (item status), `per_page` (default 10).

**Data:** Paginated **`invoice_items`** for this vendor with `invoice`, `product`, `driver.user`.

**Filter note:** `status` matches **`invoice_items.status`** (`pending`, `processing`, …).

---

### `GET /api/vendor/orders/statuses`

**Data:**

- `statuses` — all valid values
- `transitions` — map of allowed next statuses (see `App\Enums\OrderStatus`)

Use this to drive status buttons in Flutter.

---

### `GET /api/vendor/orders/{id}`

Single **`InvoiceItem`** with `invoice`, `product`, `driver`, `statusLogs`.

Extra attribute: **`allowed_next_statuses`** — array of statuses allowed from the current one (from `OrderStatusService`).

---

### `PUT /api/vendor/orders/{id}/status`

**Body:**

| Field | Rules |
|-------|--------|
| `status` | required — must be one of `OrderStatus::all()` |
| `note` | optional, max 500 |

**422** if transition invalid (`OrderStatusService` / `InvalidArgumentException`) or validation fails.

---

### `GET /api/vendor/manual-orders`

**Query:** `from_date`, `to_date`, `order_number`, `status` (at least one line item on invoice has this status), `per_page` (default 10).

**Data:** Paginated **`invoices`** (`is_manual_order` true) with nested `items` + computed `summary` per row.

---

### `POST /api/vendor/manual-orders`

**Body:**

| Field | Rules |
|-------|--------|
| `customer_name` | required, max 100 |
| `customer_phone` | optional, max 30 |
| `payment_method` | required: `Cash`, `Card`, or `Mobile` |
| `customer_paid` | optional numeric ≥ 0 (for change calculation) |
| `items` | required array, min 1 |
| `items.*.product_id` | required, exists in `products` |
| `items.*.quantity` | required integer ≥ 1 |

Products must belong to the vendor and have enough **stock**. Creates invoice with `user_id` = vendor user, items start as **`pending`**.

---

### `GET /api/vendor/manual-orders/{id}`

Invoice id. Returns `invoice`, `items`, `summary` (`item_count`, `total`, `payable`, `customer_paid`, `change`).

---

### `POST /api/vendor/manual-orders/{id}/items`

**Body:** `product_id` (required), `quantity` (required, ≥ 1).

Only while the order still has at least one **`pending`** line item. Merges quantity if the same `product_id` already exists on the invoice.

---

### `DELETE /api/vendor/manual-orders/{id}/items/{item_id}`

Removes one line item only if that line is **`pending`**. Restores stock.

---

### `POST /api/vendor/manual-orders/{id}/deliver`

**Body (optional):** `customer_paid` (numeric ≥ 0), `note` (max 500).

All items must be in **`pending`**, **`processing`**, or **`completed`**. Sets every item to **`delivered`** and logs status.

---

### `GET /api/vendor/products/barcodes`

**Query:** `search` (optional) — name or barcode, `page` (pagination, **20** per page).

Missing barcodes are auto-generated when listing. **Data:** paginator of product payload objects (`id`, `name`, `barcode`, prices, `stock`, `image`).

---

### `GET /api/vendor/products/barcode/{code}`

Resolve scan to a product for this vendor. **404** if no match.

---

### `GET /api/vendor/products/{id}/barcode`

Returns barcode payload; generates barcode if empty.

---

### `POST /api/vendor/products/{id}/barcode/regenerate`

Force new barcode string (format `PRD-{vendorId}-{productId}-{random}`).

---

### `POST /api/vendor/products/{id}/barcode/labels`

**Body:** `label_count` required integer 1–500.

**Data:** `product`, `label_count`, `print_data` (`barcode`, `product_name`, `price`, `vendor_name`, `copies`) for PDF/UI in Flutter.

---

### `GET /api/vendor/refunds`

**Query:** `status` (`pending` \| `approved` \| `rejected`), `from_date`, `to_date`, `page` (15 per page).

**Data:**

```json
{
  "summary": {
    "pending":  { "count": 0, "total": 0 },
    "approved": { "count": 0, "total": 0 },
    "rejected": { "count": 0, "total": 0 }
  },
  "refunds": { "...pagination..." }
}
```

---

### `GET /api/vendor/refunds/{id}`

Full refund for this vendor with `invoiceItem`, `invoice`, `user`, `reviewer`.

---

### `POST /api/vendor/orders/{item_id}/refund`

Same rules as buyer-initiated refunds (`RefundService::request`): item must be **delivered** or **returned**; no duplicate pending/approved refund; amount ≤ `total_pay`.

**Body:** `reason` (required), `amount` (optional partial).

**Requested by:** `vendor` on the refund record.

---

### `POST /api/vendor/refunds/{id}/approve`

Optional body `note` (passed to service). **422** if not pending.

---

### `POST /api/vendor/refunds/{id}/reject`

**Body:** `note` **required**, max 500.

---

### Wallet (`/api/vendor/wallet/...`)

Same behaviour as **driver** wallet: **show**, **transactions**, **payout**, **payouts** — see `docs/TRANSPORT_WALLET_AND_FLUTTER_API.md` for payout body (`payment_method`, `payment_details`, etc.). **No topup** route for vendor.

---

### `GET /api/vendor/drivers/available`

**Query:** `search` (optional) — partial match on driver **user name**.

**Data:** array of drivers with `is_available` true and `is_on_delivery` false.

---

### `POST /api/vendor/orders/{item_id}/assign-driver`

**Body:** `driver_id` (required, exists in `drivers`).

Creates assignment via `DriverAssignmentService::assign` (**422** on business rules, e.g. item state / existing assignment).

---

### `POST /api/vendor/orders/{item_id}/unassign-driver`

Cancels latest **active** assignment (not `rejected`, `cancelled`, or `delivered`).

---

### `GET /api/vendor/orders/{item_id}/assignment`

**Data:** `order_item` (id, status, product_id, quantity) + **`assignments`** array (all assignments for that line, newest first), with `driver.user`, `assignedBy`.

---

## Flutter tips

- One **ApiClient** with base `.../api` and `token` header.
- Normalize errors: check `status == 'success'`; if not, read `message` and optional validation `data` / `errors`.
- Use **`GET /vendor/orders/statuses`** to build status UI; use **`allowed_next_statuses`** on order detail to show only valid actions.
- Manual order id in URLs is **invoice id**; regular vendor order detail id is **invoice item id** — keep both clear in your models.
- Barcode scan: `GET .../barcode/{Uri.encodeComponent(code)}`.

---

## Source files

| Area | Controller |
|------|------------|
| Orders | `App\Http\Controllers\Api\VendorOrderController` |
| Manual orders | `App\Http\Controllers\Api\VendorManualOrderController` |
| Barcodes | `App\Http\Controllers\Api\VendorBarcodeController` |
| Refunds | `App\Http\Controllers\Api\VendorRefundController` |
| Wallet | `App\Http\Controllers\Api\WalletController` |
| Driver assign | `App\Http\Controllers\Api\VendorDriverAssignmentController` |

Routes: `routes/api.php` inside `middleware('userTypeVerify:vendor')` → `middleware('statusVerify')`.

---

## Related docs

- Buyer refunds / wallet patterns: `docs/BUYER_MODULE_AND_FLUTTER_API.md`
- Driver side after assign: `docs/DRIVER_MODULE_AND_FLUTTER_API.md`
- Payout JSON detail: `docs/TRANSPORT_WALLET_AND_FLUTTER_API.md`
