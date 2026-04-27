# Postman Testing Guide — Vendor Moderator, Activity Tracking & Inventory

Base URL: `{{base_url}}` → e.g. `http://localhost:8000/api`

---

## WHO USES WHICH API — Quick Reference

### Vendor Moderator Roles

| Endpoint | Frontend Screen | Who Calls It | Token Type |
|----------|----------------|--------------|------------|
| `POST /vendor/moderators` | Vendor Settings → Staff Management → Add Staff | **Vendor Owner** only | vendor token |
| `GET /vendor/moderators` | Vendor Settings → Staff Management → Staff List | **Vendor Owner / Manager** | vendor token |
| `GET /vendor/moderators/{id}` | Vendor Settings → Staff Management → Staff Detail | **Vendor Owner / Manager** | vendor token |
| `PUT /vendor/moderators/{id}` | Vendor Settings → Staff Management → Edit Role | **Vendor Owner / Manager** | vendor token |
| `DELETE /vendor/moderators/{id}` | Vendor Settings → Staff Management → Remove | **Vendor Owner** only | vendor token |
| `POST /login` (moderator) | Moderator Login Screen | **Vendor Sub-Account (Moderator)** | — (gets token) |
| `GET /vendor/inventory` | Vendor Dashboard → Inventory page | **Vendor Moderator** (any role) | moderator token |

---

## Role Permissions — Who can do what

### Vendor Moderator Roles

| Permission | Owner | Manager | Moderator | Support |
|---|:---:|:---:|:---:|:---:|
| Create/delete moderators | ✅ | ❌ | ❌ | ❌ |
| Update moderator role | ✅ | ✅ | ❌ | ❌ |
| View moderator list | ✅ | ✅ | ❌ | ❌ |
| Manage products (add/edit/delete) | ✅ | ✅ | ✅ | ❌ |
| Approve/reject product listings | ✅ | ✅ | ✅ | ❌ |
| Manage orders | ✅ | ✅ | ❌ | ❌ |
| View inventory | ✅ | ✅ | ✅ | ✅ |
| Handle reviews/reports | ✅ | ✅ | ❌ | ✅ |

### Activity Logs & Alerts — Admin Only

| Permission | Admin | Vendor | Buyer |
|---|:---:|:---:|:---:|
| View activity feed | ✅ | ❌ | ❌ |
| Filter activity logs | ✅ | ❌ | ❌ |
| View alerts panel | ✅ | ❌ | ❌ |
| Resolve / dismiss alerts | ✅ | ❌ | ❌ |

### Inventory — Who sees what

| Permission | Admin | Vendor Owner/Manager/Moderator/Support | Buyer |
|---|:---:|:---:|:---:|
| View own vendor inventory | — | ✅ all roles | ❌ |
| View any vendor's inventory | ✅ | ❌ | ❌ |
| Inventory auto-logged on sale | system | system | triggers on checkout |

---

## Postman Variables (set in your Collection or Environment)

| Variable      | Example value              |
|---------------|---------------------------|
| `base_url`    | `http://localhost:8000/api` |
| `vendor_token`| JWT token for a vendor user |
| `admin_token` | JWT token for an admin user |
| `vendor_id`   | ID from `vendors` table    |
| `product_id`  | ID from `products` table   |

---

## Required Headers (all authenticated endpoints)

| Header         | Value                    |
|----------------|--------------------------|
| `token`        | `{{vendor_token}}` or `{{admin_token}}` |
| `id`           | The user's `id` from DB  |
| `email`        | The user's email         |
| `Content-Type` | `application/json`       |
| `Accept`       | `application/json`       |

---

## Step 0 — Run Migrations First

```bash
php artisan migrate
```

New tables: `vendor_moderators`, `activity_logs`, `alert_logs`, `inventory_logs`

---

# PART 1 — Vendor Moderator Roles

> All requests use **vendor** token + vendor's `id` header.

---

### 1.1 Create a Moderator (Owner only)

**POST** `{{base_url}}/vendor/moderators`

**Body (raw JSON):**
```json
{
  "name": "Alice Manager",
  "email": "alice@mystore.com",
  "password": "Password123",
  "role": "Manager"
}
```

| Field    | Type   | Required | Values                              |
|----------|--------|----------|-------------------------------------|
| name     | string | yes      | Display name                        |
| email    | string | yes      | Must be unique across all users     |
| password | string | yes      | Min 8 characters                    |
| role     | string | yes      | `Manager` / `Moderator` / `Support` |

**Expected Response (201):**
```json
{
  "status": "success",
  "message": "Moderator created successfully",
  "data": {
    "id": 1,
    "vendor_id": 12,
    "user_id": 88,
    "role": "Manager",
    "is_active": true,
    "created_by_user_id": 5,
    "user": {
      "id": 88,
      "name": "Alice Manager",
      "email": "alice@mystore.com",
      "status": "Approved"
    }
  }
}
```

**Error cases:**
```json
{ "status": "failed", "message": "Email already in use.", "data": null }
{ "status": "failed", "message": "Validation failed", "data": { "role": ["The selected role is invalid."] } }
{ "status": "failed", "message": "Only the Owner can perform this action.", "data": null }
```

---

### 1.2 List All Moderators

**GET** `{{base_url}}/vendor/moderators`

**Body:** None

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Moderators fetched",
  "data": [
    {
      "id": 1,
      "vendor_id": 12,
      "user_id": 88,
      "role": "Manager",
      "is_active": true,
      "user": {
        "id": 88,
        "name": "Alice Manager",
        "email": "alice@mystore.com",
        "last_active_at": null
      }
    },
    {
      "id": 2,
      "vendor_id": 12,
      "user_id": 89,
      "role": "Support",
      "is_active": true,
      "user": { "id": 89, "name": "Bob Support", "email": "bob@mystore.com" }
    }
  ]
}
```

---

### 1.3 Get One Moderator

**GET** `{{base_url}}/vendor/moderators/1`

**Body:** None

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Moderator fetched",
  "data": {
    "id": 1,
    "vendor_id": 12,
    "user_id": 88,
    "role": "Manager",
    "is_active": true,
    "created_by_user_id": 5,
    "user": {
      "id": 88,
      "name": "Alice Manager",
      "email": "alice@mystore.com",
      "status": "Approved",
      "last_active_at": "2026-04-23T09:00:00.000000Z"
    }
  }
}
```

**Error:**
```json
{ "status": "failed", "message": "Moderator not found", "data": null }
```

---

### 1.4 Update Role or Active Status

**PUT** `{{base_url}}/vendor/moderators/1`

**Body (raw JSON):** Send only what you want to change.

Change role only:
```json
{ "role": "Moderator" }
```

Deactivate only:
```json
{ "is_active": false }
```

Both at once:
```json
{ "role": "Support", "is_active": true }
```

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Moderator updated",
  "data": {
    "id": 1,
    "role": "Moderator",
    "is_active": true,
    "user": { "id": 88, "name": "Alice Manager" }
  }
}
```

**Error:**
```json
{ "status": "failed", "message": "Cannot change the Owner role.", "data": null }
```

---

### 1.5 Delete Moderator (Owner only)

**DELETE** `{{base_url}}/vendor/moderators/1`

**Body:** None

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Moderator removed",
  "data": null
}
```

**Error:**
```json
{ "status": "failed", "message": "Cannot delete the Owner account via this endpoint.", "data": null }
```

---

### 1.6 Moderator Login (sub-account)

The moderator logs in with their own credentials via the normal login endpoint.

**POST** `{{base_url}}/login`

**Body (raw JSON):**
```json
{
  "email": "alice@mystore.com",
  "password": "Password123"
}
```

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 88,
      "name": "Alice Manager",
      "email": "alice@mystore.com",
      "user_type": "vendor",
      "status": "Approved",
      "vendor_moderator": {
        "role": "Manager",
        "is_active": true,
        "vendor_id": 12
      }
    }
  }
}
```

> Save `data.token` as `{{mod_token}}`, `data.user.id` as `{{mod_user_id}}`, and `data.user.email` as `{{mod_email}}`.  
> Use these in the headers for moderator-authenticated requests.

**Error (wrong credentials):**
```json
{ "status": "failed", "message": "Invalid credentials", "data": null }
```

**Error (deactivated account):**
```json
{ "status": "failed", "message": "Your account has been deactivated.", "data": null }
```

---

### 1.7 Moderator lists own inventory

A moderator (any role) can view their vendor's inventory using their own token.

**GET** `{{base_url}}/vendor/inventory`

**Headers:**
| Header  | Value              |
|---------|--------------------|
| `token` | `{{mod_token}}`    |
| `id`    | `{{mod_user_id}}`  |
| `email` | `{{mod_email}}`    |

**Query params (optional):**

| Param    | Example | Description            |
|----------|---------|------------------------|
| search   | `honey` | Filter by product name |
| per_page | `20`    | Default 20             |

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Inventory list fetched",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 10,
        "name": "Organic Honey 500g",
        "stock": 45,
        "vendor_id": 12,
        "images": [
          { "id": 1, "image_path": "https://example.com/storage/products/honey.jpg" }
        ],
        "inventory_logs": [
          {
            "change_type": "sale",
            "quantity_change": -3,
            "quantity_after": 45,
            "actor_name": "system",
            "created_at": "2026-04-23T10:30:00.000000Z"
          }
        ]
      },
      {
        "id": 11,
        "name": "Raw Beeswax 200g",
        "stock": 10,
        "vendor_id": 12,
        "images": [],
        "inventory_logs": [
          {
            "change_type": "restock",
            "quantity_change": 20,
            "quantity_after": 10,
            "actor_name": "vendor",
            "created_at": "2026-04-22T08:00:00.000000Z"
          }
        ]
      }
    ],
    "per_page": 20,
    "total": 2,
    "last_page": 1
  }
}
```

> The moderator sees **only their own vendor's products** — the backend resolves `vendor_id` automatically from the moderator's token. No vendor_id is needed in the request.

**Error (forbidden — role not allowed):**
```json
{ "status": "failed", "message": "Forbidden: your role (Support) cannot perform this action", "data": null }
```

---

### Quick test order — Part 1

1. **Create Manager** → POST `/vendor/moderators` with role `Manager` → save `data.id` as `{{mod_id}}`, `data.user.id` as `{{mod_user_id}}`
2. **Create Support** → POST `/vendor/moderators` with role `Support`
3. **List all** → GET `/vendor/moderators` — confirm 2 records returned
4. **Get one** → GET `/vendor/moderators/{{mod_id}}` — verify full response shape
5. **Update role** → PUT `/vendor/moderators/{{mod_id}}` with `{"role":"Moderator"}`
6. **Deactivate** → PUT `/vendor/moderators/{{mod_id}}` with `{"is_active":false}`
7. **Moderator login** → POST `/login` with moderator credentials → save returned `token` as `{{mod_token}}`, `user.id` as `{{mod_user_id}}`, `user.email` as `{{mod_email}}`
8. **Moderator lists own inventory** → GET `/vendor/inventory` using `{{mod_token}}` headers — must return only the same vendor's products
9. **Reactivate moderator** → PUT `/vendor/moderators/{{mod_id}}` with `{"is_active":true}`
10. **Delete** → DELETE `/vendor/moderators/{{mod_id}}`

---

# PART 2 — Activity Tracking (Admin Panel)

> All requests use **admin** token + admin's `id` header.

---

### 2.1 List Activity Logs (with filters)

**GET** `{{base_url}}/admin/activity-logs`

**Query params (all optional):**

| Param       | Example             | Description                         |
|-------------|---------------------|-------------------------------------|
| actor_id    | `5`                 | Filter by who performed the action  |
| action      | `banned`            | Partial match on action name        |
| severity    | `high`              | `low` / `medium` / `high` / `critical` |
| target_type | `vendor`            | `user` / `vendor` / `product` / `refund` etc. |
| date_from   | `2026-04-01`        | Start date (YYYY-MM-DD)             |
| date_to     | `2026-04-30`        | End date (YYYY-MM-DD)               |
| per_page    | `20`                | Default 20                          |

**Example:** `GET {{base_url}}/admin/activity-logs?severity=high&per_page=10`

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Activity logs fetched",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 10,
        "actor_id": 5,
        "actor_name": "Admin One",
        "actor_role": "admin",
        "action": "banned_user",
        "target_type": "user",
        "target_id": 44,
        "description": "Buyer 'John Doe' status set to Rejected",
        "severity": "critical",
        "ip_address": "127.0.0.1",
        "metadata": null,
        "created_at": "2026-04-23T10:00:00.000000Z",
        "actor": { "id": 5, "name": "Admin One", "email": "admin@app.com", "user_type": "admin" },
        "alert": {
          "id": 3,
          "activity_log_id": 10,
          "status": "pending"
        }
      }
    ],
    "per_page": 20,
    "total": 1
  }
}
```

---

### 2.2 Live Activity Feed (last 50 events)

**GET** `{{base_url}}/admin/activity-logs/feed`

**Body:** None. No filters — always returns the 50 most recent events.

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Live feed fetched",
  "data": [
    {
      "id": 10,
      "actor_id": 5,
      "actor_name": "Admin One",
      "actor_role": "admin",
      "action": "banned_user",
      "target_type": "user",
      "target_id": 44,
      "description": "Buyer 'John Doe' status set to Rejected",
      "severity": "critical",
      "color": "red",
      "created_at": "2026-04-23T10:00:00Z"
    },
    {
      "id": 9,
      "actor_name": "Admin One",
      "action": "approved_vendor",
      "severity": "medium",
      "color": "yellow",
      "created_at": "2026-04-23T09:45:00Z"
    }
  ]
}
```

> Use `color` to apply background color in the UI:
> - `green` = low, `yellow` = medium, `orange` = high, `red` = critical

---

### 2.3 Get Single Activity Log

**GET** `{{base_url}}/admin/activity-logs/10`

**Body:** None

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Activity log fetched",
  "data": {
    "id": 10,
    "actor_id": 5,
    "actor_name": "Admin One",
    "action": "banned_user",
    "target_type": "user",
    "target_id": 44,
    "description": "Buyer 'John Doe' status set to Rejected",
    "severity": "critical",
    "metadata": null,
    "created_at": "2026-04-23T10:00:00Z",
    "actor": { "id": 5, "name": "Admin One" },
    "alert": { "id": 3, "status": "pending" }
  }
}
```

---

### 2.4 Get Alerts (pending by default)

**GET** `{{base_url}}/admin/alerts`

**Query params (optional):**

| Param    | Values                              |
|----------|-------------------------------------|
| status   | `pending` (default) / `resolved` / `dismissed` |
| per_page | default 20                          |

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Alerts fetched",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 3,
        "activity_log_id": 10,
        "status": "pending",
        "resolved_by": null,
        "resolved_at": null,
        "note": null,
        "created_at": "2026-04-23T10:00:00Z",
        "activity_log": {
          "id": 10,
          "action": "banned_user",
          "severity": "critical",
          "description": "Buyer 'John Doe' status set to Rejected",
          "actor": { "id": 5, "name": "Admin One" }
        }
      }
    ],
    "total": 1
  }
}
```

---

### 2.5 Resolve an Alert

**POST** `{{base_url}}/admin/alerts/3/resolve`

**Body (raw JSON):**
```json
{ "note": "Reviewed. User was flagged for fraud. Action confirmed." }
```

`note` is optional.

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Alert resolved",
  "data": {
    "id": 3,
    "status": "resolved",
    "resolved_by": 5,
    "resolved_at": "2026-04-23T10:30:00.000000Z",
    "note": "Reviewed. User was flagged for fraud. Action confirmed."
  }
}
```

**Error (already resolved/dismissed):**
```json
{ "status": "failed", "message": "Alert is not pending", "data": null }
```

---

### 2.6 Dismiss an Alert

**POST** `{{base_url}}/admin/alerts/4/dismiss`

**Body (raw JSON):**
```json
{ "note": "False positive." }
```

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Alert dismissed",
  "data": { "id": 4, "status": "dismissed" }
}
```

---

### How to trigger activity logs (test actions that auto-log)

These existing admin endpoints now write to `activity_logs` automatically:

| Admin action | Endpoint | Logged action | Severity |
|---|---|---|---|
| Approve a vendor | `PUT /admin-vendor/{id}` with `{"status":"Approved"}` | `approved_vendor` | medium |
| Reject a vendor | `PUT /admin-vendor/{id}` with `{"status":"Rejected"}` | `rejected_vendor` | high → **alert created** |
| Ban a buyer | `PUT /buyer-status-update/{id}` with `{"status":"Rejected"}` | `banned_user` | critical → **alert created** |
| Approve refund | `POST /admin/refunds/{id}/approve` | `approved_refund` | medium |
| Reject refund | `POST /admin/refunds/{id}/reject` | `rejected_refund` | medium |
| Create moderator | `POST /vendor/moderators` | `created_moderator` | low |

---

### Quick test order — Part 2

1. **Trigger a log** → call `PUT /buyer-status-update/{id}` with `{"status":"Rejected"}` (this bans a buyer)
2. **Check feed** → GET `/admin/activity-logs/feed` — see the `banned_user` event with `color: red`
3. **Check logs (filtered)** → GET `/admin/activity-logs?severity=critical`
4. **Check alerts** → GET `/admin/alerts` — see the auto-created pending alert
5. **Resolve alert** → POST `/admin/alerts/{alert_id}/resolve` with note
6. **Check resolved** → GET `/admin/alerts?status=resolved`

---

# PART 3 — Inventory Tracking

---

## Vendor Endpoints

> Use **vendor** token + vendor's `id` header.

---

### 3.1 List All Products + Latest Stock Event

**GET** `{{base_url}}/vendor/inventory`

**Query params (optional):**

| Param    | Example      | Description              |
|----------|--------------|--------------------------|
| search   | `honey`      | Filter by product name   |
| per_page | `20`         | Default 20               |

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Inventory list fetched",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 10,
        "name": "Organic Honey 500g",
        "stock": 45,
        "vendor_id": 12,
        "images": [{ "id": 1, "image_path": "https://..." }],
        "inventory_logs": [
          {
            "change_type": "sale",
            "quantity_change": -3,
            "quantity_after": 45,
            "actor_name": "system",
            "created_at": "2026-04-23T10:30:00Z"
          }
        ]
      }
    ],
    "total": 25,
    "per_page": 20
  }
}
```

---

### 3.2 Full Log for One Product

**GET** `{{base_url}}/vendor/inventory/10`

**Query params (optional):**

| Param       | Example      | Description                                          |
|-------------|--------------|------------------------------------------------------|
| change_type | `sale`       | `sale` / `return` / `restock` / `damage` / `adjustment` |
| date_from   | `2026-04-01` | Start date                                           |
| date_to     | `2026-04-30` | End date                                             |
| per_page    | `30`         | Default 30                                           |

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Inventory log fetched",
  "data": {
    "product": { "id": 10, "name": "Organic Honey 500g", "stock": 45 },
    "logs": {
      "current_page": 1,
      "data": [
        {
          "id": 201,
          "product_id": 10,
          "vendor_id": 12,
          "actor_id": 5,
          "actor_name": "Admin One",
          "change_type": "sale",
          "quantity_before": 48,
          "quantity_change": -3,
          "quantity_after": 45,
          "note": null,
          "reference_type": "invoice",
          "reference_id": 77,
          "created_at": "2026-04-23T10:30:00Z"
        },
        {
          "id": 200,
          "change_type": "restock",
          "quantity_before": 30,
          "quantity_change": 18,
          "quantity_after": 48,
          "actor_name": "vendor",
          "reference_type": "manual",
          "created_at": "2026-04-22T08:00:00Z"
        }
      ],
      "total": 12
    }
  }
}
```

---

### 3.3 Summary View (actor + time + stock change +/-)

**GET** `{{base_url}}/vendor/inventory/10/summary`

**Body:** None

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Inventory summary fetched",
  "data": {
    "product": { "id": 10, "name": "Organic Honey 500g", "stock": 45 },
    "current_stock": 45,
    "events": [
      {
        "id": 201,
        "product_name": "Organic Honey 500g",
        "actor_name": "system",
        "change_type": "sale",
        "quantity_change": -3,
        "quantity_before": 48,
        "quantity_after": 45,
        "direction": "-",
        "note": null,
        "reference_type": "invoice",
        "reference_id": 77,
        "time": "2026-04-23T10:30:00Z"
      },
      {
        "id": 200,
        "actor_name": "vendor",
        "change_type": "restock",
        "quantity_change": 18,
        "direction": "+",
        "time": "2026-04-22T08:00:00Z"
      }
    ]
  }
}
```

> `direction` is `+` for any positive change, `-` for negative — use this for the colored badge in the UI.

---

## Admin Endpoints

> Use **admin** token + admin's `id` header.

---

### 3.4 Admin: List All Products for a Vendor

**GET** `{{base_url}}/admin/inventory/12`

Replace `12` with the target `vendor_id`.

**Query params:** `search`, `per_page` (same as vendor endpoint)

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Admin inventory list fetched",
  "data": {
    "vendor": { "id": 12, "business_name": "Honey Farm Store", "country": "Uganda" },
    "products": {
      "current_page": 1,
      "data": [
        { "id": 10, "name": "Organic Honey 500g", "stock": 45 },
        { "id": 11, "name": "Raw Beeswax", "stock": 10 }
      ],
      "total": 2
    }
  }
}
```

---

### 3.5 Admin: Full Log for One Product (under a Vendor)

**GET** `{{base_url}}/admin/inventory/12/product/10`

Replace `12` with vendor_id, `10` with product_id.

**Query params:** `change_type`, `date_from`, `date_to`, `per_page`

**Expected Response (200):**
```json
{
  "status": "success",
  "message": "Admin inventory log fetched",
  "data": {
    "product": { "id": 10, "name": "Organic Honey 500g", "stock": 45 },
    "logs": {
      "data": [ /* same shape as 3.2 */ ],
      "total": 12
    }
  }
}
```

---

### How inventory logs are created automatically

| Action | Endpoint | change_type | delta |
|---|---|---|---|
| Buyer places order | `POST /invoice/create` | `sale` | `-qty` per product |
| Admin/vendor cancels order line | `PUT /vendor/orders/{id}/status` → cancelled | `return` | `+qty` |
| Quantity reduced on a line | `PATCH /vendor/orders/{id}/quantity` | `adjustment` | delta |
| Vendor edits stock manually | `POST /product/update/{id}` with new `stock` | `adjustment` | `new - old` |

---

### Quick test order — Part 3

1. **Check current stock** → GET `/vendor/inventory` — note a product's current `stock`
2. **Place an order** → POST `/invoice/create` with `{"payment_method":"OPU"}` (buyer token) — includes a product in cart
3. **Check inventory log** → GET `/vendor/inventory/{product_id}` — see a `sale` entry with negative delta
4. **Manual restock** → POST `/product/update/{product_id}` (vendor token) with `{"stock": 100}` — see an `adjustment` entry
5. **Summary view** → GET `/vendor/inventory/{product_id}/summary` — see `+` and `-` events side by side
6. **Admin view** → GET `/admin/inventory/{vendor_id}/product/{product_id}` — same data from admin

---

# Summary of All New Endpoints

| Method | URL | Who calls it | Frontend screen | Purpose |
|--------|-----|--------------|-----------------|---------|
| `POST` | `/vendor/moderators` | Vendor **Owner** | Settings → Add Staff | Create sub-account moderator |
| `GET` | `/vendor/moderators` | Owner / Manager | Settings → Staff List | List all moderators |
| `GET` | `/vendor/moderators/{id}` | Owner / Manager | Settings → Staff Detail | Get one moderator |
| `PUT` | `/vendor/moderators/{id}` | Owner / Manager | Settings → Edit Staff | Update role / toggle active |
| `DELETE` | `/vendor/moderators/{id}` | Vendor **Owner** | Settings → Remove Staff | Remove sub-account |
| `GET` | `/admin/activity-logs` | **Admin** | Admin → Activity Log page | List logs with filters |
| `GET` | `/admin/activity-logs/feed` | **Admin** | Admin → Live Feed widget | Latest 50 events (real-time) |
| `GET` | `/admin/activity-logs/{id}` | **Admin** | Admin → Log detail popup | Single log detail |
| `GET` | `/admin/alerts` | **Admin** | Admin → Alerts Panel | List alerts |
| `POST` | `/admin/alerts/{id}/resolve` | **Admin** | Admin → Alerts → Resolve | Resolve alert with note |
| `POST` | `/admin/alerts/{id}/dismiss` | **Admin** | Admin → Alerts → Dismiss | Dismiss alert |
| `GET` | `/vendor/inventory` | Vendor / **any Moderator** (with own token) | Vendor → Inventory page | All products + latest stock event (moderator sees own vendor only) |
| `GET` | `/vendor/inventory/{product_id}` | Vendor / any Moderator | Vendor → Inventory → Expand | Full stock change log |
| `GET` | `/vendor/inventory/{product_id}/summary` | Vendor / any Moderator | Vendor → Inventory → Summary | Summary with +/- direction |
| `GET` | `/admin/inventory/{vendor_id}` | **Admin** | Admin → Vendor → Inventory tab | All products for a vendor |
| `GET` | `/admin/inventory/{vendor_id}/product/{product_id}` | **Admin** | Admin → Vendor → Product detail | Full log for one product |

