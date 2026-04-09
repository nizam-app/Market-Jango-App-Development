# Buyer: order management, wallet & refund API (Flutter)

**Base URL:** `{BASE_URL}/api` (Laravel `api` prefix on every path).

---

## API list (quick reference)

### A. Cart & checkout (`userTypeVerify:buyer`)

| # | Method | Path | Purpose |
|---|--------|------|---------|
| A1 | `GET` | `/api/cart` | Active cart lines + computed `total` |
| A2 | `POST` | `/api/cart/create` | Add/update line (`product_id`, optional `quantity`, `attributes`, `action`) |
| A3 | `DELETE` | `/api/cart/{id}` | Remove one cart row (`id` = cart item id) |
| A4 | `POST` | `/api/cart/checkout` | Checkout flow from cart (see `CartController`) |
| A5 | `POST` | `/api/cart/offer/{offerId}/add` | Add offer to cart |

### B. Orders & invoices (`tokenVerify` only — filtered by `id` header; **use buyer account**)

| # | Method | Path | Purpose |
|---|--------|------|---------|
| B1 | `POST` | `/api/invoice/create` | Create invoice from cart + `payment_method`. **Deep dive:** [FLUTTER_INVOICE_CREATE.md](./FLUTTER_INVOICE_CREATE.md) |
| B2 | `GET` | `/api/invoice` | Invoices with `delivery_status` = **`successful`** only; paginated (10/page) |
| B3 | `GET` | `/api/buyer/all-order` | All **invoice line items** for this user (flat list, `data` array; not paginated in code) |
| B4 | `GET` | `/api/InvoiceProductList/{invoice_id}` | One invoice + lines + products + vendors (must belong to user). **Path is case-sensitive (`InvoiceProductList`).** |
| B5 | `GET` | `/api/payment/verify` | Query: **`tx_ref`** (required). Verifies Flutterwave payment for **your** invoice |

### C. Tracking (`userTypeVerify:buyer`)

| # | Method | Path | Purpose |
|---|--------|------|---------|
| C1 | `GET` | `/api/buyer/invoice/tracking/details/{id}` | Status history for invoice **`id`** (`statusLogs`) |
| C2 | `GET` | `/api/buyer/orders/{order_id}/track` | Live tracking: **`order_id` = invoice id** — per-line driver + map-friendly fields |
| C3 | `GET` | `/api/buyer/orders/{order_id}/track/path` | GPS path for one line. Query: **`item_id`** (invoice item id) when multiple lines |

### D. Wallet (`userTypeVerify:buyer`)

| # | Method | Path | Purpose |
|---|--------|------|---------|
| D1 | `GET` | `/api/wallet` | Balance + summary |
| D2 | `GET` | `/api/wallet/transactions` | History. Query: `type`, `status`, `from_date`, `to_date` |
| D3 | `POST` | `/api/wallet/topup` | Self top-up (`amount`, optional `note`) — buyer allowed |
| D4 | `POST` | `/api/wallet/payout` | Withdrawal request (same body rules as vendor/driver) |
| D5 | `GET` | `/api/wallet/payouts` | My payouts. Query: optional `status` |

### E. Refunds (`userTypeVerify:buyer`)

| # | Method | Path | Purpose |
|---|--------|------|---------|
| E1 | `GET` | `/api/buyer/refunds` | My refund requests (paginated 15). Query: optional `status` |
| E2 | `GET` | `/api/buyer/refunds/{id}` | One refund + `invoiceItem`, `invoice`, `vendor`, `reviewer` |
| E3 | `POST` | `/api/buyer/orders/{item_id}/refund` | Create request — **`item_id` = invoice item id** |

**Buyer cannot approve/reject refunds** — vendor (or admin) does. When approved, **your wallet** is credited (`RefundService`).

Section details below.

---

## Authentication & headers

| Route group | Middleware |
|-------------|------------|
| Cart, wallet, refunds, §C tracking | `tokenVerify` + **`userTypeVerify:buyer`** |
| §B invoice/order listing & create | **`tokenVerify` only** (no `userTypeVerify` on route) — data scoped by **`id`** header |

**Token:** `TokenVerifyMiddleware` reads the **`token`** header (JWT). Send the same way as the rest of your app; many clients also send `Authorization: Bearer …` — align with your existing Flutter client.

**Headers commonly required:** `id` (user id), often `email` for checkout flows — see [FLUTTER_INVOICE_CREATE.md](./FLUTTER_INVOICE_CREATE.md).

**JSON envelope** (`ResponseHelper`): `{ "status", "message", "data" }`.

---

## 1. Cart

- **`GET /api/cart`** — Requires a **`buyers`** row linked to `user_id` (`CartController` loads `Buyer::where('user_id', header id)`). Returns `[carts, "total" => …]`.
- **`POST /api/cart/create`** — Body: `product_id` (required), `quantity`, `attributes` (JSON string), `action` (`increase`/`decrease`).
- **`DELETE /api/cart/{id}`** — `id` = cart row id owned by buyer.
- **`POST /api/cart/checkout`** — See `CartController::checkout` for full validation and response.
- **`POST /api/cart/offer/{offerId}/add`** — Adds offer line.

---

## 2. Create order (invoice)

**`POST /api/invoice/create`**

Body includes **`payment_method`** and relies on active cart + buyer shipping fields. Full field list, payment URL flow, and Flutter samples: **[FLUTTER_INVOICE_CREATE.md](./FLUTTER_INVOICE_CREATE.md)**.

---

## 3. List & detail orders

| Endpoint | Behaviour |
|----------|-----------|
| **`GET /api/invoice`** | Only invoices where **`delivery_status`** is **`successful`**. Pagination: 10 per page. Includes `items` + `items.product`. |
| **`GET /api/buyer/all-order`** | All **`InvoiceItem`** rows for user, with `invoice` + `product`, ordered by id desc. Wrapped as `data` in response. |
| **`GET /api/InvoiceProductList/{invoice_id}`** | Full invoice if `user_id` matches. Includes items, product images, vendors. |

---

## 4. Payment verify

**`GET /api/payment/verify?tx_ref=<value>`**

- Validates `tx_ref` required.
- Finds invoice by `tax_ref` + **`user_id`** from header `id`.
- Calls Flutterwave verify; returns `verified`, `transaction_id`, `amount`, etc. on success.

---

## 5. Tracking

| Endpoint | ID meaning |
|----------|------------|
| **`GET /api/buyer/invoice/tracking/details/{id}`** | **`id`** = **invoice id** |
| **`GET /api/buyer/orders/{order_id}/track`** | **`order_id`** = **invoice id** (not a line id). Response includes `items[]` with `item_id`, driver, `live_location`, `timeline`. |
| **`GET /api/buyer/orders/{order_id}/track/path`** | **`order_id`** = invoice id. Query **`item_id`** = invoice item id (use when multiple lines; otherwise first item may be used). Returns `path` array of GPS points. |

---

## 6. Wallet

Same controller as other roles: **`WalletController`** + **`WalletService`**.

| Endpoint | Notes |
|----------|--------|
| **`GET /api/wallet`** | Summary: `balance`, `currency`, `total_credited`, `total_debited`, `by_type`. |
| **`GET /api/wallet/transactions`** | Paginated (20); nested under `data.transactions`. |
| **`POST /api/wallet/topup`** | Body: `amount` (required, min 0.01), `note` optional. **Buyer is allowed** (sandbox direct credit in controller). |
| **`POST /api/wallet/payout`** | Body: `amount` (min 1), `payment_method` (`bank_transfer` \| `mobile_money` \| `paypal` \| `cash`), `payment_details` with `account` + `name`, optional `note`. |
| **`GET /api/wallet/payouts`** | Paginated (15); optional `status`. |

For field-level parity with vendor wallet docs, see [VENDOR_WALLET_AND_REFUND_API.md](./VENDOR_WALLET_AND_REFUND_API.md) §1–4 (same shapes, different path prefix: buyer uses **`/api/wallet`** not `/api/vendor/wallet`).

---

## 7. Refunds

### 7.1 Request refund

**`POST /api/buyer/orders/{item_id}/refund`**

- **`item_id`** = **invoice item id** (same id as in `buyer/all-order` / `InvoiceProductList` lines).
- Body: **`reason`** (required, max 1000), **`amount`** (optional partial refund, min 0.01).

**Rules** (`RefundService`): line must be **`delivered`** or **`returned`**; no duplicate pending/approved refund for same line; amount ≤ line `total_pay`.

**Success:** `201`, `data` = new `Refund` (`status`: `pending`).

### 7.2 List & show

- **`GET /api/buyer/refunds`** — Optional query **`status`**: `pending` \| `approved` \| `rejected`. Paginate 15. Includes `invoiceItem.product`, `invoice`, `vendor`.
- **`GET /api/buyer/refunds/{id}`** — Same ownership check; richer relations including `reviewer`.

### 7.3 After approval

Vendor (or admin flow) approves → buyer **wallet** credited with `type` **`refund`**. Buyer app should refresh **`GET /api/wallet`** / transactions.

---

## 8. Flutter checklist

1. Use **`user_type: buyer`** JWT for cart, wallet, refunds, and §C tracking routes or you get **403**.
2. **`order_id` in tracking URLs = invoice id**; **`item_id` in refund URL = invoice item id** — do not swap.
3. **`GET /api/invoice`** ≠ all orders; use **`/buyer/all-order`** or **`InvoiceProductList`** for full history / detail.
4. Ensure **`Buyer`** profile + shipping coords exist before **`invoice/create`** (see invoice doc).
5. Send **`token`** (+ `id` / `email` as your app already does) on every call.

---

## 9. Implementation references

| Area | Files |
|------|--------|
| Routes | `routes/api.php` — `userTypeVerify:buyer` block + shared `tokenVerify` invoice routes |
| Cart | `app/Http/Controllers/Api/CartController.php` |
| Invoice / orders | `app/Http/Controllers/Api/InvoiceController.php` |
| Tracking | `app/Http/Controllers/Api/BuyerTrackingController.php` |
| Wallet | `app/Http/Controllers/Api/WalletController.php`, `app/Services/WalletService.php` |
| Refunds | `app/Http/Controllers/Api/BuyerRefundController.php`, `app/Services/RefundService.php` |

Index: [FLUTTER_API_BY_ROLE.md](./FLUTTER_API_BY_ROLE.md) §1.
