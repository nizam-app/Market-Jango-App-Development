# API Documentation - Milestone 2 Features

This document contains all the new API endpoints for Milestone 2 features with Postman testing details.

**📖 Admin APIs:** All admin-specific APIs are documented separately in **[ADMIN_API_DOCUMENTATION.md](./ADMIN_API_DOCUMENTATION.md)**

## 📋 Quick Reference: Who Uses What & Where

### ✅ Currently Implemented APIs

| API | User Type | Mobile App | Admin Panel | Status |
|-----|-----------|------------|-------------|--------|
| **Subscription - Get Plans** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Subscription - Get Current** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Subscription - Subscribe** | Vendor, Driver | ✅ | ❌ | ✅ Ready |


| **Visibility - Set** | Vendor | ✅ | ❌ | ✅ Ready |
| **Visibility - Get** | Vendor | ✅ | ❌ | ✅ Ready |
| **Visibility - List** | Vendor | ✅ | ❌ | ✅ Ready |
| **Visibility - Update** | Vendor | ✅ | ❌ | ✅ Ready |
| **Visibility - Delete** | Vendor | ✅ | ❌ | ✅ Ready |
| **Affiliate - Generate** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Affiliate - Get Links** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Affiliate - Get Details** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Affiliate - Track Click** | Public | ✅ | ❌ | ✅ Ready |
| **Affiliate - Track Conversion** | Public | ✅ | ❌ | ✅ Ready |
| **Affiliate - Statistics** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Affiliate - Update** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Affiliate - Delete** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Ranking - Vendors** | Buyer, Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Ranking - Drivers** | Buyer, Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Ranking - My Rank** | Vendor, Driver | ✅ | ❌ | ✅ Ready |
| **Ranking - Recalculate** | Admin | ❌ | ✅ | ✅ Ready |

### 📱 Mobile App Usage:
- **Vendor App**: Subscription screen, Product Management screen, Visibility Management screen
- **Driver App**: Subscription screen
- **Buyer App**: Product browsing (visibility filtering happens automatically)

### 🖥️ Admin Panel Usage:
- **See `ADMIN_API_DOCUMENTATION.md` for all admin-specific APIs**

**📖 For detailed usage guide, see `API_USAGE_GUIDE.md`**

---

## Table of Contents
- [Subscription System](#subscription-system)
  - [Get Subscription Plans](#1-get-subscription-plans)
  - [Get Current Subscription](#2-get-current-subscription)
  - [Subscribe to Plan](#3-subscribe-to-plan)
- [Product Visibility Management](#product-visibility-management)
  - [Set Product Visibility](#1-set-product-visibility)
  - [Get Product Visibility](#2-get-product-visibility)
  - [Get All Vendor Visibilities](#3-get-all-vendor-visibilities)
  - [Update Visibility](#4-update-visibility)
  - [Delete Visibility](#5-delete-visibility)
- [Affiliate Link System](#affiliate-link-system)
  - [Generate Affiliate Link](#1-generate-affiliate-link)
  - [Get All Affiliate Links](#2-get-all-affiliate-links)
  - [Get Affiliate Link Details](#3-get-affiliate-link-details)
  - [Track Affiliate Click](#4-track-affiliate-click-public---no-auth-required)
  - [Track Conversion](#5-track-conversion-public---no-auth-required)
  - [Get Affiliate Statistics](#6-get-affiliate-statistics)
  - [Update Affiliate Link](#7-update-affiliate-link)
  - [Delete Affiliate Link](#8-delete-affiliate-link)
- [Priority Ranking System](#priority-ranking-system)
  - [Get Ranked Vendors](#1-get-ranked-vendors)
  - [Get Ranked Drivers](#2-get-ranked-drivers)
  - [Get My Rank](#3-get-my-rank)
  - [Recalculate Rankings (Admin)](#4-recalculate-rankings-admin)
- [Admin APIs](#admin-apis)
  - **📖 See `ADMIN_API_DOCUMENTATION.md` for all admin-specific APIs**

---

## Authentication

All endpoints require authentication via JWT token in the header:
```
token: Bearer {your_jwt_token}
```

The token should be obtained from the login endpoint:
- **Endpoint**: `POST /api/login`
- **Body**:
```json
{
  "email": "vendor@example.com",
  "password": "password123"
}
```

---

## Testing Notes

- Base URL: `http://127.0.0.1:8000/api`
- User ID and user type are automatically extracted from JWT token
- All subscription endpoints work for both `vendor` and `driver` user types

---

## Subscription System

**Who Can Use:** Vendors & Drivers  
**Where:** Mobile App (Subscription/Premium Screen)  
**Authentication:** Required (JWT Token)

### 1. Get Subscription Plans

Get all available subscription plans for vendors or drivers.

**Endpoint:** `GET /api/subscription/plans`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Query Parameters (Optional):**
- None (user type is automatically detected from token)

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Subscription plans retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Basic Plan",
      "description": "Basic subscription for small vendors",
      "price": "29.99",
      "currency": "USD",
      "billing_period": "monthly",
      "category_limit": 5,
      "image_limit": 10,
      "visibility_limit": 3,
      "has_affiliate": false,
      "has_priority_ranking": false,
      "priority_boost": 0,
      "for_user_type": "vendor",
      "status": "active",
      "sort_order": 1,
      "created_at": "2026-01-28T00:00:00.000000Z",
      "updated_at": "2026-01-28T00:00:00.000000Z"
    },
    {
      "id": 2,
      "name": "Premium Plan",
      "description": "Premium subscription with all features",
      "price": "99.99",
      "currency": "USD",
      "billing_period": "monthly",
      "category_limit": 0,
      "image_limit": 0,
      "visibility_limit": 0,
      "has_affiliate": true,
      "has_priority_ranking": true,
      "priority_boost": 100,
      "for_user_type": "vendor",
      "status": "active",
      "sort_order": 2,
      "created_at": "2026-01-28T00:00:00.000000Z",
      "updated_at": "2026-01-28T00:00:00.000000Z"
    }
  ]
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/subscription/plans`
3. Headers Tab:
   - Key: `token`
   - Value: `Bearer {your_jwt_token}`
4. Send the request

---

### 2. Get Current Subscription

**Who Can Use:** Vendors & Drivers  
**Where:** Mobile App (Subscription/Premium Screen)  
**Authentication:** Required (JWT Token)

Get the current active subscription for the logged-in vendor or driver.

**Endpoint:** `GET /api/subscription/current`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200 with subscription):**
```json
{
  "status": "success",
  "message": "Current subscription retrieved successfully",
  "data": {
    "subscription": {
      "id": 1,
      "user_id": 5,
      "subscription_plan_id": 2,
      "start_date": "2026-01-01",
      "end_date": "2026-02-01",
      "renewal_date": "2026-02-01",
      "status": "active",
      "payment_status": "paid",
      "amount_paid": "99.99",
      "payment_method": "stripe",
      "transaction_id": "txn_123456",
      "auto_renew": true,
      "plan": {
        "id": 2,
        "name": "Premium Plan",
        "price": "99.99",
        ...
      }
    },
    "usage": {
      "categories_used": 3,
      "categories_limit": 0,
      "images_used": 15,
      "images_limit": 0,
      "visibility_locations_used": 2,
      "visibility_limit": 0
    }
  }
}
```

**Response (Success - 200 no subscription):**
```json
{
  "status": "success",
  "message": "No active subscription found",
  "data": null
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/subscription/current`
3. Headers Tab:
   - Key: `token`
   - Value: `Bearer {your_jwt_token}`
4. Send the request

---

### 3. Subscribe to Plan

**Who Can Use:** Vendors & Drivers  
**Where:** Mobile App (Subscription/Premium Screen)  
**Authentication:** Required (JWT Token)

Subscribe to a subscription plan.

**Endpoint:** `POST /api/subscription/subscribe`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body (JSON):**
```json
{
  "subscription_plan_id": 2,
  "payment_method": "stripe",
  "transaction_id": "txn_123456789"
}
```

**Field Descriptions:**
- `subscription_plan_id` (required): ID of the subscription plan to subscribe to
- `payment_method` (optional): Payment method used (e.g., "stripe", "paypal")
- `transaction_id` (optional): Transaction ID from payment gateway

**Response (Success - 201):**
```json
{
  "status": "success",
  "message": "Subscription activated successfully",
  "data": {
    "subscription": {
      "id": 1,
      "user_id": 5,
      "subscription_plan_id": 2,
      "start_date": "2026-01-28",
      "end_date": "2026-02-28",
      "renewal_date": "2026-02-28",
      "status": "active",
      "payment_status": "paid",
      "amount_paid": "99.99",
      "payment_method": "stripe",
      "transaction_id": "txn_123456789",
      "auto_renew": true,
      "plan": {
        "id": 2,
        "name": "Premium Plan",
        ...
      }
    }
  }
}
```

**Response (Error - 400):**
```json
{
  "status": "failed",
  "message": "You already have an active subscription",
  "data": null
}
```

**Response (Error - 403):**
```json
{
  "status": "failed",
  "message": "This plan is not available for your user type",
  "data": null
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/subscription/subscribe`
3. Headers Tab:
   - Key: `token`
   - Value: `Bearer {your_jwt_token}`
   - Key: `Content-Type`
   - Value: `application/json`
4. Body Tab:
   - Select: `raw`
   - Select: `JSON`
   - Paste the JSON body above
5. Send the request

**Important Notes:**
- Make sure you're logged in as a **vendor** to subscribe to vendor plans (plan_id: 1, 2, or 3)
- Make sure you're logged in as a **driver** to subscribe to driver plans (plan_id: 4 or 5)
- If you get "This plan is not available for your user type", you may need to **log in again** to get a fresh token with userType included
- The system will automatically fetch your userType from the database if it's not in the token (backward compatibility)

---

---

## Product Visibility Management

**Who Can Use:** Vendors Only  
**Where:** Mobile App (Product Management / Visibility Management Screen)  
**Authentication:** Required (JWT Token)

Control where your products are visible based on Country, State, and Town. This feature respects your subscription limits.

### 1. Set Product Visibility

**Who Can Use:** Vendors Only  
**Where:** Mobile App (Product Management Screen - when creating/editing products)

Set visibility for a product in specific locations.

**Endpoint:** `POST /api/product-visibility/set`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body (JSON):**
```json
{
  "product_id": 1,
  "country": "USA",
  "state": "California",
  "town": "Los Angeles",
  "is_active": true
}
```

**Field Descriptions:**
- `product_id` (required): ID of the product
- `country` (optional): Country name
- `state` (optional): State/Province name
- `town` (optional): City/Town name
- `is_active` (optional): Whether this visibility is active (default: true)

**Note:** Leave all location fields null/empty to make product globally visible.

**Response (Success - 201):**
```json
{
  "status": "success",
  "message": "Product visibility set successfully",
  "data": {
    "visibility": {
      "id": 1,
      "product_id": 1,
      "country": "USA",
      "state": "California",
      "town": "Los Angeles",
      "is_active": true,
      "created_at": "2026-01-28T00:00:00.000000Z",
      "updated_at": "2026-01-28T00:00:00.000000Z"
    },
    "usage": {
      "used": 1,
      "limit": 3
    }
  }
}
```

**Response (Error - 403 - Limit Reached):**
```json
{
  "status": "failed",
  "message": "You have reached your visibility limit (3 locations). Please upgrade your subscription.",
  "data": null
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/product-visibility/set`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "product_id": 1,
  "country": "USA",
  "state": "California",
  "town": "Los Angeles"
}
```

---

### 2. Get Product Visibility

**Who Can Use:** Vendors Only  
**Where:** Mobile App (Product Details/Edit Screen)

Get all visibility settings for a specific product.

**Endpoint:** `GET /api/product-visibility/product/{product_id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Product visibility retrieved successfully",
  "data": {
    "product": {
      "id": 1,
      "name": "Product Name",
      "visibility_country": "USA",
      "visibility_state": "California",
      "visibility_town": "Los Angeles",
      "is_globally_visible": false
    },
    "visibilities": [
      {
        "id": 1,
        "product_id": 1,
        "country": "USA",
        "state": "California",
        "town": "Los Angeles",
        "is_active": true
      },
      {
        "id": 2,
        "product_id": 1,
        "country": "USA",
        "state": "New York",
        "town": "New York City",
        "is_active": true
      }
    ]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/product-visibility/product/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 3. Get All Vendor Visibilities

**Who Can Use:** Vendors Only  
**Where:** Mobile App (Visibility Management Screen)

Get all visibility settings for all your products.

**Endpoint:** `GET /api/product-visibility/vendor`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Visibilities retrieved successfully",
  "data": [
    {
      "id": 1,
      "product_id": 1,
      "country": "USA",
      "state": "California",
      "town": "Los Angeles",
      "is_active": true,
      "product": {
        "id": 1,
        "name": "Product Name",
        "vendor_id": 5
      }
    }
  ]
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/product-visibility/vendor`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 4. Update Visibility

**Who Can Use:** Vendors Only  
**Where:** Mobile App (Visibility Management Screen)

Update an existing visibility setting.

**Endpoint:** `PUT /api/product-visibility/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body (JSON):**
```json
{
  "country": "USA",
  "state": "Texas",
  "town": "Houston",
  "is_active": true
}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Visibility updated successfully",
  "data": {
    "id": 1,
    "product_id": 1,
    "country": "USA",
    "state": "Texas",
    "town": "Houston",
    "is_active": true
  }
}
```

**Postman Setup:**
1. Method: `PUT`
2. URL: `http://127.0.0.1:8000/api/product-visibility/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "state": "Texas",
  "town": "Houston"
}
```

---

### 5. Delete Visibility

**Who Can Use:** Vendors Only  
**Where:** Mobile App (Visibility Management Screen)

Delete a visibility setting.

**Endpoint:** `DELETE /api/product-visibility/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Visibility deleted successfully",
  "data": null
}
```

**Postman Setup:**
1. Method: `DELETE`
2. URL: `http://127.0.0.1:8000/api/product-visibility/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

---

## Affiliate Link System

**Who Can Use:** Vendors & Drivers (with affiliate feature in subscription)  
**Where:** Mobile App (Affiliate Screen)  
**Authentication:** Required (JWT Token) - except for public tracking endpoints

Generate, track, and manage affiliate links. Only available for users with affiliate feature in their subscription plan.

### 1. Generate Affiliate Link

**Who Can Use:** Vendors & Drivers (with affiliate subscription feature)  
**Where:** Mobile App (Affiliate Screen)

Create a new affiliate link.

**Endpoint:** `POST /api/affiliate/generate`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body (JSON):**
```json
{
  "name": "My Affiliate Link",
  "description": "Link for promoting my products",
  "destination_url": "https://example.com/products",
  "expires_at": "2026-12-31"
}
```

**Field Descriptions:**
- `name` (optional): Name for the affiliate link
- `description` (optional): Description of the link
- `destination_url` (optional): URL to redirect to when clicked
- `expires_at` (optional): Expiration date (YYYY-MM-DD)

**Response (Success - 201):**
```json
{
  "status": "success",
  "message": "Affiliate link generated successfully",
  "data": {
    "affiliate_link": {
      "id": 1,
      "user_id": 5,
      "link_code": "ABC12345",
      "name": "My Affiliate Link",
      "description": "Link for promoting my products",
      "destination_url": "https://example.com/products",
      "clicks": 0,
      "conversions": 0,
      "conversion_rate": "0.00",
      "revenue": "0.00",
      "status": "active",
      "expires_at": "2026-12-31",
      "created_at": "2026-01-28T00:00:00.000000Z"
    },
    "full_url": "http://127.0.0.1:8000/affiliate/ABC12345"
  }
}
```

**Response (Error - 403 - No Affiliate Access):**
```json
{
  "status": "failed",
  "message": "Affiliate feature is not available in your current subscription plan. Please upgrade to a plan with affiliate features.",
  "data": null
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/affiliate/generate`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "name": "My Affiliate Link",
  "destination_url": "https://example.com"
}
```

---

### 2. Get All Affiliate Links

**Who Can Use:** Vendors & Drivers (with affiliate subscription feature)  
**Where:** Mobile App (Affiliate Screen)

Get all affiliate links for the logged-in user.

**Endpoint:** `GET /api/affiliate/links`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Affiliate links retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 5,
      "link_code": "ABC12345",
      "name": "My Affiliate Link",
      "clicks": 150,
      "conversions": 12,
      "revenue": "1200.00",
      "conversion_rate": "8.00",
      "status": "active",
      "total_clicks": 150,
      "total_conversions": 12
    }
  ]
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/affiliate/links`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 3. Get Affiliate Link Details

**Who Can Use:** Vendors & Drivers (with affiliate subscription feature)  
**Where:** Mobile App (Affiliate Analytics Screen)

Get detailed information about a specific affiliate link including click history.

**Endpoint:** `GET /api/affiliate/link/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Affiliate link details retrieved successfully",
  "data": {
    "affiliate_link": {
      "id": 1,
      "link_code": "ABC12345",
      "name": "My Affiliate Link",
      "clicks": 150,
      "conversions": 12,
      "revenue": "1200.00",
      "clicks": [
        {
          "id": 1,
          "ip_address": "192.168.1.1",
          "device_type": "mobile",
          "converted": true,
          "conversion_value": "100.00",
          "created_at": "2026-01-28T00:00:00.000000Z"
        }
      ]
    },
    "full_url": "http://127.0.0.1:8000/affiliate/ABC12345",
    "statistics": {
      "total_clicks": 150,
      "total_conversions": 12,
      "conversion_rate": "8.00",
      "total_revenue": "1200.00",
      "clicks_today": 5,
      "conversions_today": 1,
      "clicks_by_device": [
        {"device_type": "mobile", "count": 100},
        {"device_type": "desktop", "count": 50}
      ]
    }
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/affiliate/link/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 4. Track Affiliate Click (Public - No Auth Required)

**Who Can Use:** Public (Anyone clicking the affiliate link)  
**Where:** Web/Mobile App (Automatic redirect when link is clicked)  
**Authentication:** Not Required (Public Endpoint)

Track when someone clicks an affiliate link. This is a public endpoint.

**Endpoint:** `GET /api/affiliate/click/{link_code}`

**Headers:** None required

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Click tracked successfully",
  "data": {
    "click_id": 123,
    "redirect_url": "https://example.com/products"
  }
}
```

**Note:** This endpoint should be called when someone clicks your affiliate link. The system will:
- Track the click
- Record IP, device type, referrer
- Increment click count
- Return redirect URL

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/affiliate/click/ABC12345`
3. No headers needed (public endpoint)

---

### 5. Track Conversion (Public - No Auth Required)

**Who Can Use:** Public (System/Backend calls this when conversion happens)  
**Where:** Backend Integration (Called automatically on signup/purchase)  
**Authentication:** Not Required (Public Endpoint)

Track when someone converts (signs up/purchases) via affiliate link.

**Endpoint:** `POST /api/affiliate/conversion/{link_code}`

**Headers:**
```
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "conversion_value": 100.00,
  "click_id": 123
}
```

**Field Descriptions:**
- `conversion_value` (optional): Value of the conversion (e.g., purchase amount)
- `click_id` (optional): ID of the click that led to conversion

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Conversion tracked successfully",
  "data": {
    "link": {
      "id": 1,
      "clicks": 151,
      "conversions": 13,
      "revenue": "1300.00",
      "conversion_rate": "8.61"
    }
  }
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/affiliate/conversion/ABC12345`
3. Headers:
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "conversion_value": 100.00,
  "click_id": 123
}
```

---

### 6. Get Affiliate Statistics

**Who Can Use:** Vendors & Drivers (with affiliate subscription feature)  
**Where:** Mobile App (Affiliate Analytics Screen)

Get overall statistics for all affiliate links.

**Endpoint:** `GET /api/affiliate/statistics`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Statistics retrieved successfully",
  "data": {
    "statistics": {
      "total_links": 5,
      "active_links": 4,
      "total_clicks": 500,
      "total_conversions": 45,
      "total_revenue": "4500.00",
      "overall_conversion_rate": 9.00,
      "clicks_today": 25,
      "conversions_today": 3
    },
    "top_links": [
      {
        "id": 1,
        "name": "My Best Link",
        "link_code": "ABC12345",
        "clicks": 200,
        "conversions": 20,
        "revenue": "2000.00",
        "conversion_rate": "10.00"
      }
    ]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/affiliate/statistics`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 7. Update Affiliate Link

**Who Can Use:** Vendors & Drivers (with affiliate subscription feature)  
**Where:** Mobile App (Affiliate Management Screen)

Update an existing affiliate link.

**Endpoint:** `PUT /api/affiliate/link/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body (JSON):**
```json
{
  "name": "Updated Link Name",
  "status": "inactive",
  "destination_url": "https://newurl.com"
}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Affiliate link updated successfully",
  "data": {
    "id": 1,
    "name": "Updated Link Name",
    "status": "inactive"
  }
}
```

**Postman Setup:**
1. Method: `PUT`
2. URL: `http://127.0.0.1:8000/api/affiliate/link/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "name": "Updated Link Name",
  "status": "inactive"
}
```

---

### 8. Delete Affiliate Link

**Who Can Use:** Vendors & Drivers (with affiliate subscription feature)  
**Where:** Mobile App (Affiliate Management Screen)

Delete an affiliate link.

**Endpoint:** `DELETE /api/affiliate/link/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Request Body:** None

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Affiliate link deleted successfully",
  "data": null
}
```

**Postman Setup:**
1. Method: `DELETE`
2. URL: `http://127.0.0.1:8000/api/affiliate/link/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

## Admin APIs

**📖 All admin-specific APIs are documented in a separate file:**

👉 **[ADMIN_API_DOCUMENTATION.md](./ADMIN_API_DOCUMENTATION.md)**

This includes:
- Subscription Plan Management (Create, Read, Update, Delete)
- Ranking Recalculation
- Delivery Charge Management (Dashboard, Zone Routes, Weight Charges)

---

## Next Steps

After testing these affiliate APIs, we'll implement:
- Priority Ranking System
- Vendor Analytics
- Delivery Charge Settings
- Transport Additional Features

---

## Priority Ranking System

**Who Can Use:**  
- Buyers (Mobile App) to see ranked vendor/driver lists  
- Vendors/Drivers (Mobile App) to see their own rank  
- Admin (Admin Panel) to trigger recalculation  

**Where:** Mobile App (Buyer listing screens + Vendor/Driver profile/analytics) and Admin Panel (maintenance)  
**Authentication:** Required (JWT Token), except none of these are public.

### 1. Get Ranked Vendors

**Who Can Use:** Buyer, Vendor, Driver  
**Where:** Buyer App (Home/Search vendor listing), Vendor/Driver can also view rankings  

**Endpoint:** `GET /api/ranking/vendors`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Query Params (Optional):**
- `country` (string)
- `state` (string)
- `town` (string)
- `category_id` (int)
- `per_page` (int, default 20, max 100)

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Ranked vendors retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 10,
        "business_name": "Vendor A",
        "country": "USA",
        "address": "California, Los Angeles",
        "avg_rating": 4.8,
        "click": 120,
        "boost_value": 100,
        "organic_score": 600,
        "priority_score": 700,
        "rank": 1
      }
    ],
    "per_page": 20,
    "total": 50
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/ranking/vendors?country=USA&state=California&per_page=20`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 2. Get Ranked Drivers

**Who Can Use:** Buyer, Vendor, Driver  
**Where:** Buyer App (Driver listing/search), Vendor/Driver can also view rankings  

**Endpoint:** `GET /api/ranking/drivers`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Query Params (Optional):**
- `country` (string) *(filtered via `drivers.location` text)*
- `state` (string) *(filtered via `drivers.location` text)*
- `town` (string) *(filtered via `drivers.location` text)*
- `per_page` (int, default 20, max 100)

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Ranked drivers retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 5,
        "car_name": "Toyota",
        "car_model": "Prius",
        "location": "USA, California, Los Angeles",
        "rating": 5,
        "boost_value": 50,
        "organic_score": 50,
        "priority_score": 100,
        "rank": 1
      }
    ],
    "per_page": 20,
    "total": 22
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/ranking/drivers?state=California`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 3. Get My Rank

**Who Can Use:** Vendor, Driver  
**Where:** Vendor/Driver App (Analytics/Profile screen)  

**Endpoint:** `GET /api/ranking/me`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Vendor rank retrieved successfully",
  "data": {
    "user_type": "vendor",
    "rank": 3,
    "organic_score": 420,
    "boost_value": 100,
    "priority_score": 520
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/ranking/me`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 4. Recalculate Rankings (Admin)

**Who Can Use:** Admin  
**Where:** Admin Panel (maintenance button / cron trigger)  

**Note:** This is an admin-only endpoint. For full documentation, see `ADMIN_API_DOCUMENTATION.md`.

**Endpoint:** `POST /api/ranking/recalculate`

**Quick Reference:**
- **Headers:** `token: Bearer {admin_jwt_token}`
- **Body:** `{"type": "vendor" | "driver" | "all"}`
- **Response:** Returns count of vendors/drivers updated

**Full Documentation:** See `ADMIN_API_DOCUMENTATION.md` → Priority Ranking Management

---

## 5. Vendor Dashboard / Management Screen APIs

### Overview

These APIs provide comprehensive dashboard data for vendors and drivers, aggregating subscription, analytics, affiliate, payment, visibility, and category management information. Admin APIs are also included for managing subscription plans.

---

### 1. Get Subscription Screen

**Who Can Use:** Vendor, Driver  
**Where:** Mobile App (Subscription Management Screen)

**Endpoint:** `GET /api/vendor-dashboard/subscription`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Subscription screen data retrieved",
  "data": {
    "current_subscription": {
      "id": 1,
      "user_id": 5,
      "subscription_plan_id": 2,
      "start_date": "2026-01-15",
      "end_date": "2026-02-15",
      "status": "active",
      "payment_status": "paid",
      "amount_paid": "29.99",
      "plan": {
        "id": 2,
        "name": "Premium Plan",
        "price": "29.99",
        "category_limit": 10,
        "image_limit": 50,
        "visibility_limit": 5,
        "has_affiliate": true,
        "has_priority_ranking": true
      }
    },
    "usage": {
      "categories_used": 3,
      "categories_limit": 10,
      "images_used": 15,
      "images_limit": 50,
      "visibility_locations_used": 2,
      "visibility_limit": 5
    },
    "available_plans": [...],
    "history": [...]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/subscription`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 2. Get Analytics Screen

**Who Can Use:** Vendor  
**Where:** Mobile App (Analytics Dashboard Screen)

**Endpoint:** `GET /api/vendor-dashboard/analytics?days=30`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Query Parameters:**
- `days` (optional): Number of days for analytics (default: 30)

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Analytics data retrieved",
  "data": {
    "period": {
      "days": 30,
      "start_date": "2025-12-29",
      "end_date": "2026-01-28"
    },
    "overview": {
      "total_revenue": 12500.50,
      "total_orders": 45,
      "average_order_value": 277.79,
      "total_clicks": 320,
      "conversion_rate": 14.06
    },
    "weekly_sales": {
      "days": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
      "current_period": [1200, 1500, 1800, 2000, 2200, 2500, 3000],
      "previous_period": [1000, 1300, 1600, 1900, 2100, 2400, 2800]
    },
    "top_products": [
      {
        "product_id": 10,
        "name": "Product A",
        "total_quantity": 150,
        "total_revenue": 4500.00
      }
    ],
    "revenue_by_category": [
      {
        "category_id": 3,
        "category_name": "Electronics",
        "revenue": 8000.00,
        "order_count": 25
      }
    ]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/analytics?days=30`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 3. Get Affiliate Screen

**Who Can Use:** Vendor, Driver (with affiliate feature)  
**Where:** Mobile App (Affiliate Management Screen)

**Endpoint:** `GET /api/vendor-dashboard/affiliate`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Affiliate screen data retrieved",
  "data": {
    "summary": {
      "total_links": 5,
      "total_clicks": 1250,
      "total_conversions": 45,
      "total_revenue": 2250.00,
      "overall_conversion_rate": 3.60
    },
    "links": [
      {
        "id": 1,
        "link_code": "AFF123456",
        "name": "Main Affiliate Link",
        "clicks": 500,
        "conversions": 20,
        "revenue": 1000.00,
        "conversion_rate": 4.00,
        "status": "active"
      }
    ],
    "recent_activity": [
      {
        "date": "2026-01-28",
        "clicks": 25,
        "conversions": 2
      }
    ]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/affiliate`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 4. Get Payment Management Screen

**Who Can Use:** Vendor, Driver  
**Where:** Mobile App (Payment Management Screen)

**Endpoint:** `GET /api/vendor-dashboard/payments`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Payment data retrieved",
  "data": {
    "subscription_payments": {
      "total_paid": 89.97,
      "payments": [
        {
          "id": 1,
          "subscription_plan_id": 2,
          "amount_paid": "29.99",
          "payment_method": "stripe",
          "transaction_id": "txn_123456",
          "created_at": "2026-01-15T10:00:00.000000Z",
          "start_date": "2026-01-15",
          "end_date": "2026-02-15",
          "plan": {
            "name": "Premium Plan",
            "price": "29.99"
          }
        }
      ]
    },
    "order_payments": {
      "total_revenue": 12500.50,
      "payments": [
        {
          "id": 100,
          "user_id": 10,
          "total": "250.00",
          "status": "Complete",
          "payment_method": "FW",
          "created_at": "2026-01-28T10:00:00.000000Z",
          "items": [...]
        }
      ]
    }
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/payments`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 5. Get Visibility Management Screen

**Who Can Use:** Vendor  
**Where:** Mobile App (Visibility Management Screen)

**Endpoint:** `GET /api/vendor-dashboard/visibility`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Visibility data retrieved",
  "data": {
    "summary": {
      "total_visibilities": 15,
      "unique_locations": 5
    },
    "usage": {
      "locations_used": 5,
      "locations_limit": 10,
      "can_add_more": true
    },
    "by_product": [
      {
        "product_id": 10,
        "product_name": "Product A",
        "visibilities": [...],
        "count": 3
      }
    ],
    "all_visibilities": [...]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/visibility`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 6. Get Category Management Screen

**Who Can Use:** Vendor  
**Where:** Mobile App (Category Management Screen)

**Endpoint:** `GET /api/vendor-dashboard/categories`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Category data retrieved",
  "data": {
    "summary": {
      "total_categories": 5
    },
    "usage": {
      "categories_used": 5,
      "categories_limit": 10,
      "can_add_more": true
    },
    "my_categories": [
      {
        "id": 3,
        "name": "Electronics",
        "products_count": 25
      }
    ],
    "available_categories": [
      {
        "id": 1,
        "name": "Clothing",
        "description": "All clothing items"
      }
    ]
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/categories`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 7. Add Category to Vendor

**Who Can Use:** Vendor  
**Where:** Mobile App (Category Management Screen)

**Endpoint:** `POST /api/vendor-dashboard/categories/add`

**Headers:**
```
token: Bearer {your_jwt_token}
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "category_id": 5
}
```

**Response (Success - 201):**
```json
{
  "status": "success",
  "message": "Category added successfully",
  "data": {
    "id": 5,
    "name": "Home & Garden",
    "description": "Home and garden products"
  }
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/categories/add`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "category_id": 5
}
```

---

### 8. Remove Category from Vendor

**Who Can Use:** Vendor  
**Where:** Mobile App (Category Management Screen)

**Endpoint:** `DELETE /api/vendor-dashboard/categories/{category_id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Category removed successfully",
  "data": null
}
```

**Postman Setup:**
1. Method: `DELETE`
2. URL: `http://127.0.0.1:8000/api/vendor-dashboard/categories/5`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 9-12. Admin Subscription Plan Management

**Who Can Use:** Admin Only  
**Where:** Admin Panel (Manage Plans Screen)

**Note:** These are admin-only endpoints. For full documentation, see `ADMIN_API_DOCUMENTATION.md`.

**Endpoints:**
- `GET /api/vendor-dashboard/admin/plans` - Get all plans
- `POST /api/vendor-dashboard/admin/plans` - Create plan
- `PUT /api/vendor-dashboard/admin/plans/{id}` - Update plan
- `DELETE /api/vendor-dashboard/admin/plans/{id}` - Delete plan

**Full Documentation:** See `ADMIN_API_DOCUMENTATION.md` → Subscription Plan Management

---

## 6. Delivery Charge Setting APIs

### Overview

These APIs manage delivery charges through multiple systems:

**Already Implemented:**
1. **Product/Quantity-based charges** - Already existed (5 endpoints)
2. **Weight-based delivery charges** - Already existed via `/api/weights` (WeightController)

**Newly Added:**
3. **Zone-based delivery routes** - NEW APIs for zone-to-zone delivery pricing (table existed but no APIs)
4. **Delivery charge dashboard** - NEW aggregated view of all charge types
5. **Delivery charge calculation** - NEW smart calculation with priority rules

---

### 1. Get All Product-Based Delivery Charges (Already Existed)

**Who Can Use:** Vendor  
**Where:** Mobile App (Delivery Settings Screen)

**Endpoint:** `GET /api/delivery-charge/vendor`

**Note:** This endpoint was already implemented before.

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "All delivery charge successfully fetched",
  "data": [
    {
      "id": 1,
      "delivery_charge": "50.00",
      "vendor_id": 2,
      "quantity": 5,
      "product_id": 10
    }
  ]
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/vendor`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 2. Create Product-Based Delivery Charge (Already Existed)

**Who Can Use:** Vendor  
**Where:** Mobile App (Delivery Settings Screen)

**Endpoint:** `POST /api/delivery-charge/create`

**Note:** This endpoint was already implemented before.

**Headers:**
```
token: Bearer {your_jwt_token}
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "quantity": 5,
  "delivery_charge": "50.00",
  "product_id": 10
}
```

**Response (Success - 201):**
```json
{
  "status": "success",
  "message": "delivery Charge successfully created",
  "data": {
    "id": 1,
    "quantity": 5,
    "delivery_charge": "50.00",
    "vendor_id": 2,
    "product_id": 10
  }
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/create`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "quantity": 5,
  "delivery_charge": "50.00",
  "product_id": 10
}
```

---

### 3. Update Product-Based Delivery Charge

**Who Can Use:** Vendor  
**Where:** Mobile App (Delivery Settings Screen)

**Endpoint:** `POST /api/delivery-charge/update/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "quantity": 10,
  "delivery_charge": "75.00"
}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Delivery charge successfully updated",
  "data": {
    "id": 1,
    "quantity": 10,
    "delivery_charge": "75.00",
    "vendor_id": 2,
    "product_id": 10
  }
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/update/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "quantity": 10,
  "delivery_charge": "75.00"
}
```

---

### 4. Delete Product-Based Delivery Charge

**Who Can Use:** Vendor  
**Where:** Mobile App (Delivery Settings Screen)

**Endpoint:** `POST /api/delivery-charge/destroy/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "delivery charge successfully deleted",
  "data": null
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/destroy/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 5. Get Zone-Based Delivery Routes (NEW)

**Who Can Use:** Vendor, Admin  
**Where:** Mobile App / Admin Panel (Delivery Settings Screen)

**Note:** Admin can manage all routes (global + vendor-specific). See `ADMIN_API_DOCUMENTATION.md` for admin-specific features.

**Endpoint:** `GET /api/delivery-charge/zone-routes`

**Note:** This is a NEW endpoint. The `delivery_routes` table existed but had no APIs.

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Zone delivery routes retrieved",
  "data": [
    {
      "id": 1,
      "from_zone_id": 1,
      "to_zone_id": 2,
      "vendor_id": null,
      "base_charge": "100.00",
      "per_km_charge": "5.00",
      "min_charge": "50.00",
      "max_charge": "500.00",
      "status": "Active",
      "from_zone": {
        "id": 1,
        "name": "Zone A"
      },
      "to_zone": {
        "id": 2,
        "name": "Zone B"
      }
    }
  ]
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/zone-routes`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 6. Create Zone-Based Delivery Route

**Who Can Use:** Vendor, Admin  
**Where:** Mobile App / Admin Panel (Delivery Settings Screen)

**Endpoint:** `POST /api/delivery-charge/zone-routes`

**Headers:**
```
token: Bearer {your_jwt_token}
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "from_zone_id": 1,
  "to_zone_id": 2,
  "base_charge": 100.00,
  "per_km_charge": 5.00,
  "min_charge": 50.00,
  "max_charge": 500.00,
  "status": "Active"
}
```

**Note:** Admin can also include `vendor_id` to create vendor-specific routes. Vendors can only create their own routes.

**Response (Success - 201):**
```json
{
  "status": "success",
  "message": "Zone delivery route created successfully",
  "data": {
    "id": 1,
    "from_zone_id": 1,
    "to_zone_id": 2,
    "vendor_id": 2,
    "base_charge": "100.00",
    "per_km_charge": "5.00",
    "min_charge": "50.00",
    "max_charge": "500.00",
    "status": "Active"
  }
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/zone-routes`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "from_zone_id": 1,
  "to_zone_id": 2,
  "base_charge": 100.00,
  "per_km_charge": 5.00,
  "min_charge": 50.00,
  "max_charge": 500.00,
  "status": "Active"
}
```

---

### 7. Update Zone-Based Delivery Route

**Who Can Use:** Vendor, Admin  
**Where:** Mobile App / Admin Panel (Delivery Settings Screen)

**Endpoint:** `PUT /api/delivery-charge/zone-routes/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "base_charge": 120.00,
  "per_km_charge": 6.00,
  "status": "Inactive"
}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Zone delivery route updated successfully",
  "data": {
    "id": 1,
    "base_charge": "120.00",
    "per_km_charge": "6.00",
    "status": "Inactive"
  }
}
```

**Postman Setup:**
1. Method: `PUT`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/zone-routes/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "base_charge": 120.00,
  "per_km_charge": 6.00,
  "status": "Inactive"
}
```

---

### 8. Delete Zone-Based Delivery Route

**Who Can Use:** Vendor, Admin  
**Where:** Mobile App / Admin Panel (Delivery Settings Screen)

**Endpoint:** `DELETE /api/delivery-charge/zone-routes/{id}`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Zone delivery route deleted successfully",
  "data": null
}
```

**Postman Setup:**
1. Method: `DELETE`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/zone-routes/1`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 9. Weight-Based Delivery Charges (Already Existed)

**Who Can Use:** Admin  
**Where:** Admin Panel (Delivery Settings Screen)

**Note:** Weight-based delivery charges are managed via the existing `/api/weights` endpoints:
- `GET /api/weights` - Get all weight-based charges
- `GET /api/weights/{id}` - Get single weight charge
- `POST /api/weights` - Create weight charge
- `PUT /api/weights/{id}` - Update weight charge
- `DELETE /api/weights/{id}` - Delete weight charge

**Full Documentation:** See `ADMIN_API_DOCUMENTATION.md` → Delivery Charge Management → Manage Weight-Based Delivery Charges

---

### 10. Get Delivery Charge Dashboard (NEW)

**Who Can Use:** Vendor, Admin  
**Where:** Mobile App / Admin Panel (Delivery Settings Screen)

**Note:** Admin sees all delivery charges (vendor-specific + global). Vendors only see their own. See `ADMIN_API_DOCUMENTATION.md` for admin view details.

**Endpoint:** `GET /api/delivery-charge/dashboard`

**Headers:**
```
token: Bearer {your_jwt_token}
```

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Delivery charge dashboard retrieved",
  "data": {
    "product_based": {
      "total": 5,
      "charges": [...]
    },
    "zone_routes": {
      "total": 10,
      "vendor_specific": 3,
      "global": 7,
      "routes": [...]
    },
    "weight_based": {
      "total": 4,
      "charges": [...]
    }
  }
}
```

**Postman Setup:**
1. Method: `GET`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/dashboard`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`

---

### 11. Calculate Delivery Charge (NEW)

**Who Can Use:** Buyer, Vendor, Admin  
**Where:** Mobile App (Checkout Screen)

**Endpoint:** `POST /api/delivery-charge/calculate`

**Headers:**
```
token: Bearer {your_jwt_token}
Content-Type: application/json
```

**Request Body (JSON):**
```json
{
  "product_id": 10,
  "quantity": 5,
  "from_zone_id": 1,
  "to_zone_id": 2,
  "weight": 2.5,
  "weight_unit": "kg",
  "distance_km": 10
}
```

**Priority Rules:**
1. Product/Quantity-based charge (highest priority)
2. Zone-based charge (if zones provided)
3. Weight-based charge (if weight provided and no product charge)

**Response (Success - 200):**
```json
{
  "status": "success",
  "message": "Delivery charge calculated",
  "data": {
    "product_id": 10,
    "quantity": 5,
    "charges_applied": {
      "product_based": "50.00",
      "zone_based": "150.00"
    },
    "final_delivery_charge": 150.00
  }
}
```

**Postman Setup:**
1. Method: `POST`
2. URL: `http://127.0.0.1:8000/api/delivery-charge/calculate`
3. Headers:
   - `token`: `Bearer {your_jwt_token}`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
```json
{
  "product_id": 10,
  "quantity": 5,
  "from_zone_id": 1,
  "to_zone_id": 2,
  "weight": 2.5,
  "weight_unit": "kg",
  "distance_km": 10
}
```

---
