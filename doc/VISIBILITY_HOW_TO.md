# How to Set and Use Product Visibility in This Application

This document explains how **Product Visibility** works in the Market Jango app and how to set, get, list, update, and delete visibility for vendor products.

---

## What Is Product Visibility?

Product Visibility lets **vendors** control **where** their products are visible:

- By **country**, **state**, and **town**
- Or **globally** (leave location fields empty)
- Visibility count is limited by the vendor’s **subscription plan** (e.g. “X visibility locations”)

**Who can use it:** Vendors only (Vendor app)  
**Where it’s used:** Product Management screen (when creating/editing products) and Visibility Management screen.

---

## Quick Reference

| Action        | Method | Endpoint                               | Use case                          |
|---------------|--------|----------------------------------------|-----------------------------------|
| **Set**       | POST   | `/api/product-visibility/set`          | Add visibility for a product      |
| **Get**       | GET    | `/api/product-visibility/product/{id}` | Get visibility for one product   |
| **List**      | GET    | `/api/product-visibility/vendor`       | List all your visibilities       |
| **Update**    | PUT    | `/api/product-visibility/{id}`        | Change a visibility rule          |
| **Delete**    | DELETE | `/api/product-visibility/{id}`         | Remove a visibility rule          |
| **Dashboard** | GET    | `/api/vendor-dashboard/visibility`     | Summary + usage for UI screen     |

All requests need the vendor JWT in the `token` header: `Bearer {your_jwt_token}`.

---

## 1. Set Product Visibility

Use this when creating/editing a product to define where it is visible (country, state, town). Leave all location fields null/empty for **global** visibility.

- **Endpoint:** `POST /api/product-visibility/set`
- **Headers:** `token: Bearer {your_jwt_token}`, `Content-Type: application/json`

**Request body (JSON):**

```json
{
  "product_id": 1,
  "country": "USA",
  "state": "California",
  "town": "Los Angeles",
  "is_active": true
}
```

| Field        | Required | Description                                      |
|-------------|----------|--------------------------------------------------|
| `product_id`| Yes      | ID of the product                                |
| `country`   | No       | Country name                                     |
| `state`     | No       | State/Province                                   |
| `town`      | No       | City/Town                                        |
| `is_active` | No      | Whether this visibility is active (default: true) |

**Note:** Leave `country`, `state`, and `town` null/empty to make the product **globally visible**.

**Success (201):** Returns the created visibility and usage (e.g. `used`, `limit`).  
**Error (403):** e.g. “You have reached your visibility limit. Please upgrade your subscription.”

---

## 2. Get Product Visibility

Get all visibility rules for **one product** (e.g. on product details or edit screen).

- **Endpoint:** `GET /api/product-visibility/product/{product_id}`
- **Headers:** `token: Bearer {your_jwt_token}`

**Example:** `GET /api/product-visibility/product/1`

**Response:** Product info plus `visibilities` array (id, product_id, country, state, town, is_active).

---

## 3. List All Vendor Visibilities

Get all visibility rules for **all** your products (e.g. Visibility Management screen).

- **Endpoint:** `GET /api/product-visibility/vendor`
- **Headers:** `token: Bearer {your_jwt_token}`

**Response:** Array of visibility objects, each with product info (e.g. id, name, vendor_id).

---

## 4. Update Visibility

Change an existing visibility rule (e.g. change location or turn it off).

- **Endpoint:** `PUT /api/product-visibility/{id}`
- **Headers:** `token: Bearer {your_jwt_token}`, `Content-Type: application/json`

**Request body (JSON):**

```json
{
  "country": "USA",
  "state": "Texas",
  "town": "Houston",
  "is_active": true
}
```

Send only the fields you want to change. **Success (200):** Returns the updated visibility object.

---

## 5. Delete Visibility

Remove a visibility rule.

- **Endpoint:** `DELETE /api/product-visibility/{id}`
- **Headers:** `token: Bearer {your_jwt_token}`

**Example:** `DELETE /api/product-visibility/1`  
**Success (200):** `"Visibility deleted successfully"`, `data: null`.

---

## 6. Visibility Management Screen (Dashboard)

Use this to power the **Visibility Management** screen: summary, usage vs limit, and data by product.

- **Endpoint:** `GET /api/vendor-dashboard/visibility`
- **Headers:** `token: Bearer {your_jwt_token}`

**Response includes:**

- `summary`: e.g. `total_visibilities`, `unique_locations`
- `usage`: `locations_used`, `locations_limit`, `can_add_more`
- `by_product`: per-product visibility list and count
- `all_visibilities`: full list of visibility rules

Use `usage.locations_used` and `usage.locations_limit` to show “X / Y visibility” and disable “Add” when the limit is reached.

---

## Where This Is Used in the App

- **Vendor app**
  - **Product Management:** When adding/editing a product, call **Set** (and optionally **Get** for that product).
  - **Visibility Management screen:** Use **List** or **Dashboard** to show all rules; use **Update** and **Delete** for editing/removing.
- **Subscription screen:** Shows visibility usage (e.g. “Visibility: X / Y”) from current subscription or dashboard visibility usage.
- **Buyer app:** No direct calls; visibility filtering is applied by the backend when listing products.

---

## Base URL

Use the same base URL as the rest of the app (e.g. from `global_api.dart`). Example:

- Base: `http://127.0.0.1:8000` (or your server)
- Set: `POST http://127.0.0.1:8000/api/product-visibility/set`
- Dashboard: `GET http://127.0.0.1:8000/api/vendor-dashboard/visibility`

---

For full request/response examples and Postman steps, see **API_DOCUMENTATION.md** → **Product Visibility Management** and **Get Visibility Management Screen**.
