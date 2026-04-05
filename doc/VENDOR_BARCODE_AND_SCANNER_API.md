# Barcode and scanner system (vendor APIs)

**বাংলা সারাংশ:** এই ব্যাকএন্ডে বারকোড ফিচার **শুধু ভেন্ডার** এর জন্য। প্রোডাক্টে `barcode` স্ট্রিং সংরক্ষিত থাকে; লিস্ট/শো/প্রিন্ট করার সময় বারকোড না থাকলে সার্ভার **অটো জেনারেট** করতে পারে। **স্ক্যান** মানে `GET` দিয়ে সেই কোড পাঠিয়ে নিজের স্টোরের ম্যাচিং প্রোডাক্ট পাওয়া—ম্যানুয়াল অর্ডারে লাইন যোগ ক্লায়েন্ট সাইডে (`POST /vendor/manual-orders/.../items`) করে।

**English summary:** Five authenticated **vendor** endpoints under `/api` manage product barcodes, **scan lookup**, **regeneration**, and **print-label payload**. Barcodes are stored on `products.barcode` (unique, nullable). There is **no** separate buyer/driver barcode API in this phase.

---

## Authentication and placement

- **Prefix:** `/api`
- **Middleware:** `tokenVerify` + `userTypeVerify:vendor` + `statusVerify` (same group as other vendor tools).
- **Headers:** e.g. `Authorization: Bearer <token>`, `id` = vendor’s **user** id, `user_type: vendor`.

**Controller:** `App\Http\Controllers\Api\VendorBarcodeController`

---

## Barcode value format

Generated server-side when missing or on **regenerate**:

```
PRD-{vendorId padded 4}-{productId padded 6}-{4 random alphanumeric}
```

Example: `PRD-0007-000042-A3F9`

- Intended to be **CODE-128 / QR friendly** (alphanumeric + hyphens).
- **Globally unique** in `products.barcode` (collision loop until unique).

---

## Standard product payload (`data`)

Most success responses wrap this object (or a paginated list of it):

| Field           | Type    | Description |
|-----------------|---------|-------------|
| `id`            | int     | Product id |
| `name`          | string  | Product name |
| `barcode`       | string  | Scannable value (may be auto-created) |
| `sell_price`    | float   | Sell price |
| `regular_price` | float   | Regular price |
| `stock`         | int     | Stock |
| `image`         | string  | Product image path/URL as stored |

---

## Endpoints

### 1. `GET /api/vendor/products/barcodes`

**Purpose:** Paginated list of **active** products (`is_active = '1'`) for the logged-in vendor, each with barcode payload.

**Query (optional):**

| Parameter | Description |
|-----------|-------------|
| `search`  | Substring match on **name** OR **barcode** |
| `page`    | Laravel pagination page |

**Pagination:** 20 items per page, ordered by `name`.

**Side effect:** Any product on the **current page** that still has `barcode = null` gets a generated barcode and is **saved** before the response.

---

### 2. `GET /api/vendor/products/barcode/{code}` — **scanner**

**Purpose:** Mobile/web scanner sends the **raw string** read from the camera; API returns the product **only if** it belongs to this vendor.

**Path parameter:** `code` — the full barcode string.

**Client note:** If the barcode contains characters that are not URL-safe (e.g. `#`, `+`, `/`, spaces), **URL-encode** the `code` segment when building the request.

**Responses:**

- `200` — `success`, product payload in `data`
- `404` — unknown code or product owned by another vendor (`No product found with this barcode`)

---

### 3. `GET /api/vendor/products/{id}/barcode`

**Purpose:** Barcode screen for one product: returns the same payload as above for **own** product `id`.

**Side effect:** If `barcode` is empty, generates, saves, then returns.

---

### 4. `POST /api/vendor/products/{id}/barcode/regenerate`

**Purpose:** Always assign a **new** barcode (damaged label, security rotation, etc.). Persists to DB.

**Body:** none required.

---

### 5. `POST /api/vendor/products/{id}/barcode/labels` — **print labels**

**Purpose:** Returns structured data so the app can render or export labels (PDF, etc.); **does not** generate a server-side PDF file.

**Body (JSON):**

| Field         | Required | Rules |
|---------------|----------|--------|
| `label_count` | yes      | integer, 1–500 |

**Response `data` shape:**

```json
{
  "product": { "...": "same as productPayload" },
  "label_count": 10,
  "print_data": {
    "barcode": "PRD-...",
    "product_name": "...",
    "price": 9.99,
    "vendor_name": "...",
    "copies": 10
  }
}
```

**Side effect:** If product had no barcode, one is generated and saved before building `print_data`.

---

## Flow: scan → manual order (app-side)

1. `GET /api/vendor/products/barcode/{code}` → get `id`, `sell_price`, `stock`, etc.
2. Use `POST /api/vendor/manual-orders` or `POST /api/vendor/manual-orders/{invoice_id}/items` with `product_id` + `quantity` (see [VENDOR_ORDER_MANAGEMENT_AND_BILLING.md](./VENDOR_ORDER_MANAGEMENT_AND_BILLING.md)).

The barcode API does **not** add cart lines by itself.

---

## Database

- Migration: `database/migrations/2026_03_17_000003_phase3_add_barcode_to_products.php` — column `products.barcode` (`string(50)`, nullable, **unique**).

---

## Tests

Feature coverage: `tests/Feature/Phase3/VendorBarcodeTest.php` (list, search, show, scan, regenerate, labels, cross-vendor isolation).

---

## Quick reference

| Action              | Method | Path |
|---------------------|--------|------|
| List + search       | GET    | `/api/vendor/products/barcodes` |
| Scan                | GET    | `/api/vendor/products/barcode/{code}` |
| One product barcode | GET    | `/api/vendor/products/{id}/barcode` |
| New barcode         | POST   | `/api/vendor/products/{id}/barcode/regenerate` |
| Print label data    | POST   | `/api/vendor/products/{id}/barcode/labels` |
