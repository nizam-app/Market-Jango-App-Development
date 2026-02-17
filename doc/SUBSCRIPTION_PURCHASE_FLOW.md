# Subscription Purchase Flow – Mobile App (Flutter)

This document describes **how a vendor or driver can purchase a subscription plan from the mobile app**: the process, APIs, and payment handling. Share this with your Flutter developer.

---

## 1. Overview

- **Who can subscribe:** Vendors and Drivers (each sees plans for their user type).
- **Auth:** All subscription APIs require the JWT **token** in the request header (same as login).
- **Payment:** You can use either:
  - **Flutterwave (recommended):** Backend creates a payment link; app opens it in browser/webview. After user pays, Flutterwave redirects to our server, we activate the subscription and redirect back to the app. See **Section 2A** and **API 4** below.
  - **Other gateways or manual:** App collects payment (e.g. Stripe SDK), then calls **Subscribe** with `transaction_id`. See **Section 2B** and **API 3**.

---

## 2A. User Flow with Flutterwave (backend-initiated payment)

| Step | What happens | API to call |
|------|----------------|-------------|
| 1 | User opens Subscription / Premium screen | — |
| 2 | App loads available plans | `GET /api/subscription/plans` |
| 3 | (Optional) App loads current subscription | `GET /api/subscription/current` |
| 4 | User selects a plan and taps “Pay” | — |
| 5 | App calls backend to get Flutterwave payment link | `POST /api/subscription/initiate-payment` |
| 6 | Backend returns `payment_url` | — |
| 7 | App opens `payment_url` in browser or in-app webview | — |
| 8 | User completes payment on Flutterwave | — |
| 9 | Flutterwave redirects to our callback; backend activates subscription and redirects user to your success URL (e.g. app deep link) | *(backend)* |
| 10 | App receives user back (deep link or webview close); app calls `GET /api/subscription/current` to show the new subscription | `GET /api/subscription/current` |

---

## 2B. User Flow (app-collected payment, then Subscribe)

| Step | What happens | API to call |
|------|----------------|-------------|
| 1 | User opens Subscription / Premium screen | — |
| 2 | App loads available plans for this user type | `GET /api/subscription/plans` |
| 3 | App shows plans; user selects a plan | — |
| 4 | App shows plan price and “Pay” / “Subscribe” | — |
| 5 | User taps Pay → app opens payment (e.g. Stripe/PayPal) | *(handled in app)* |
| 6 | Payment succeeds → app gets `transaction_id` (and method) | *(from payment SDK)* |
| 7 | App calls backend to activate subscription | `POST /api/subscription/subscribe` |
| 8 | Backend returns active subscription | Show success and new subscription in app |
| 9 | (Optional) App loads current subscription + usage | `GET /api/subscription/current` |

---

## 3. API Details

**Base URL:** `https://your-api-domain.com/api` (or `http://127.0.0.1:8000/api` for local testing)

**Required header for all requests:**
```
token: Bearer {jwt_token}
```
Use the same JWT the user got at login. The backend reads `user_id` and `user_type` from this token.

---

### API 1: Get subscription plans

**When:** On opening the subscription screen (and when refreshing the list).

**Request:**
- **Method:** `GET`
- **URL:** `/api/subscription/plans`
- **Headers:** `token: Bearer {jwt_token}`
- **Optional header:** `user_type: vendor` or `user_type: driver` (if you want to filter by type; otherwise backend can use type from token)
- **Body:** None

**Response (200):**
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
      "sort_order": 1
    }
  ]
}
```

**Notes for app:**
- Show only plans where `for_user_type` matches the logged-in user (`vendor` or `driver`) or `for_user_type` is `"both"`.
- Use `price`, `currency`, `billing_period`, `name`, `description` for the plan card and payment amount.

---

### API 2: Get current subscription (optional but recommended)

**When:** On subscription screen load (to show “You’re on Basic Plan” or “No active plan”) and after a successful purchase.

**Request:**
- **Method:** `GET`
- **URL:** `/api/subscription/current`
- **Headers:** `token: Bearer {jwt_token}`
- **Body:** None

**Response – has subscription (200):**
```json
{
  "status": "success",
  "message": "Current subscription retrieved successfully",
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
      "transaction_id": "txn_xxx",
      "auto_renew": true,
      "plan": {
        "id": 2,
        "name": "Premium Plan",
        "price": "99.99",
        "currency": "USD",
        "billing_period": "monthly",
        "category_limit": 0,
        "image_limit": 0,
        "visibility_limit": 0,
        "has_affiliate": true,
        "has_priority_ranking": true,
        "priority_boost": 100
      }
    },
    "usage": {
      "categories_used": 3,
      "categories_limit": 5,
      "images_used": 10,
      "images_limit": 20,
      "visibility_locations_used": 2,
      "visibility_limit": 3
    }
  }
}
```

**Response – no subscription (200):**
```json
{
  "status": "success",
  "message": "No active subscription found",
  "data": null
}
```

**Notes for app:**
- If `data` is `null`, show “No active plan” and the list of plans.
- If `data.subscription` exists, show current plan and use `usage` for progress (e.g. “3/5 categories used”).

---

### API 3: Subscribe (purchase) – call after payment success

**When:** **Only after** the user has successfully paid in the app (Stripe/PayPal/etc.). Send the plan ID and the payment gateway’s transaction ID and method.

**Request:**
- **Method:** `POST`
- **URL:** `/api/subscription/subscribe`
- **Headers:**
  - `token: Bearer {jwt_token}`
  - `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "subscription_plan_id": 2,
  "payment_method": "stripe",
  "transaction_id": "txn_123456789"
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `subscription_plan_id` | **Yes** | ID from “Get subscription plans” (e.g. `plan.id`) |
| `payment_method` | No | e.g. `"stripe"`, `"paypal"`, `"flutterwave"` |
| `transaction_id` | No | Transaction/payment ID from the payment gateway (recommended to send for records) |

**Response – success (201):**
```json
{
  "status": "success",
  "message": "Subscription activated successfully",
  "data": {
    "subscription": {
      "id": 1,
      "user_id": 5,
      "subscription_plan_id": 2,
      "start_date": "2026-02-16",
      "end_date": "2026-03-16",
      "renewal_date": "2026-03-16",
      "status": "active",
      "payment_status": "paid",
      "amount_paid": "99.99",
      "payment_method": "stripe",
      "transaction_id": "txn_123456789",
      "auto_renew": true,
      "plan": {
        "id": 2,
        "name": "Premium Plan",
        "price": "99.99",
        "currency": "USD",
        "billing_period": "monthly",
        "category_limit": 0,
        "image_limit": 0,
        "visibility_limit": 0,
        "has_affiliate": true,
        "has_priority_ranking": true,
        "priority_boost": 100
      }
    }
  }
}
```

**Response – already has active subscription (400):**
```json
{
  "status": "failed",
  "message": "You already have an active subscription",
  "data": null
}
```

**Response – wrong plan type (403):**
```json
{
  "status": "failed",
  "message": "This plan is not available for your user type. Your type: vendor, Plan type: driver",
  "data": null
}
```

**Notes for app:**
- Call this **only after** payment succeeds in the app.
- If you get **400**, user already has an active plan → show “You already have an active subscription” and optionally load current subscription with API 2.
- If you get **403**, do not show this plan to this user type (filter by `for_user_type` when showing plans).

---

### API 4: Initiate Flutterwave payment (get payment link)

**When:** User has selected a plan and tapped “Pay”. Use this when paying with **Flutterwave** so the backend creates the payment and returns a link to open in browser/webview.

**Request:**
- **Method:** `POST`
- **URL:** `/api/subscription/initiate-payment`
- **Headers:**
  - `token: Bearer {jwt_token}`
  - `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "subscription_plan_id": 2
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `subscription_plan_id` | **Yes** | ID of the plan (from Get plans). |

**Response – success (200):**
```json
{
  "status": "success",
  "message": "Payment link created",
  "data": {
    "payment_url": "https://checkout.flutterwave.com/...",
    "tx_ref": "sub_5_2_20260216120000_abc123",
    "pending_id": 1,
    "amount": "99.99",
    "currency": "USD"
  }
}
```

**Response – error (400/403/502):** Same as Subscribe for 400/403; 502 if Flutterwave credentials are missing or Flutterwave fails.

**What the app must do:**
1. Call this API with the selected `subscription_plan_id`.
2. On success, open `data.payment_url` in a **browser** or **in-app webview**.
3. User completes payment on Flutterwave. Flutterwave then redirects to our backend; the backend activates the subscription and redirects the user to the URL you configured (e.g. `SUBSCRIPTION_SUCCESS_REDIRECT_URL` – app deep link like `marketjango://subscription/success?status=success&tx_ref=...`).
4. When the app is opened again (via deep link or when user returns from browser), call `GET /api/subscription/current` to show the new subscription. You can also use the deep link query params `status` and `tx_ref` to show a success message.

**Backend configuration (for your server/.env):**
- `FLW_SECRET_KEY` – Flutterwave secret key
- `FLW_PAYMENT_INIT_URL` – `https://api.flutterwave.com/v3/payments`
- `SUBSCRIPTION_PAYMENT_CALLBACK_URL` – Full URL where Flutterwave redirects after payment (e.g. `https://your-api.com/api/subscription/payment/callback`)
- `SUBSCRIPTION_SUCCESS_REDIRECT_URL` – Where to send the user after successful payment (e.g. `marketjango://subscription/success` or a web page)
- `SUBSCRIPTION_FAIL_REDIRECT_URL` – Where to send the user after failed/cancelled payment (e.g. `marketjango://subscription/failed`)

---

## 4. Payment: Who Does What

**Option A – Flutterwave (backend-initiated):**
- Backend creates the payment via Flutterwave and returns a **payment_url**.
- App opens this URL in browser/webview. User pays on Flutterwave. Flutterwave redirects to our callback; we activate the subscription and redirect the user to your success URL (e.g. app deep link). No payment SDK needed in the app for Flutterwave.

**Option B – Other gateways (app-collected payment):**
- Backend does **not** charge the user. The **mobile app** integrates a payment SDK (e.g. Stripe, PayPal), uses the plan’s `price` and `currency`, and on success calls `POST /api/subscription/subscribe` with `subscription_plan_id`, `payment_method`, and `transaction_id`. The app must **never** call Subscribe before payment success.

---

## 5. Recommended App Flow (Summary)

**If using Flutterwave:**
1. Screen open: call `GET /api/subscription/current` and `GET /api/subscription/plans`.
2. User selects a plan and taps Pay: call `POST /api/subscription/initiate-payment` with `subscription_plan_id`.
3. Open the returned `payment_url` in browser or webview. User pays on Flutterwave.
4. When user returns to the app (deep link or webview close), call `GET /api/subscription/current` to show the new subscription.

**If using another gateway (e.g. Stripe in-app):**
1. Screen open: call `GET /api/subscription/current` and `GET /api/subscription/plans`.
2. User selects a plan and taps Pay: open your payment SDK with `plan.price` and `plan.currency`.
3. On payment success: call `POST /api/subscription/subscribe` with `subscription_plan_id`, `payment_method`, `transaction_id`. On 201, show success and optionally call `GET /api/subscription/current`.

---

## 6. Quick Reference

| Purpose | Method | Endpoint | When |
|--------|--------|----------|------|
| List plans | GET | `/api/subscription/plans` | Subscription screen load |
| Current subscription + usage | GET | `/api/subscription/current` | Screen load / after purchase |
| **Get Flutterwave payment link** | **POST** | **`/api/subscription/initiate-payment`** | **When user taps Pay (Flutterwave flow)** |
| Activate subscription (other gateways) | POST | `/api/subscription/subscribe` | After payment success in app |

All authenticated requests need header: `token: Bearer {jwt_token}`. The callback URL (`/api/subscription/payment/callback`) is called by Flutterwave (no auth).

---

## 7. Full API Documentation

For full request/response examples and Postman setup, see **API_DOCUMENTATION.md** → **Subscription System** section.
