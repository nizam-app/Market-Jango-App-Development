# Vendor Products API

একটি নির্দিষ্ট ভেন্ডরের সব প্রোডাক্ট পেজিনেশনে দেখার জন্য এই API ব্যবহার করা হয়।

---

## Endpoint

| Method | URL |
|--------|-----|
| **GET** | `{{baseurl}}/api/product/vendor/{id}` |

**Path parameter:**

| Name | Type   | Required | Description        |
|------|--------|----------|--------------------|
| `id` | integer| Yes      | ভেন্ডরের ID (যেমন: `1`) |

---

## Authentication

এই API **টোকেন ভেরিফাই** মিডলওয়্যারের আওতায় আছে। রিকোয়েস্টে হেডারে টোকেন পাঠাতে হবে।

| Header | Value        | Description        |
|--------|--------------|--------------------|
| `token`| `{{buyerToken}}` | লগইনকৃত বায়ার ইউজারের টোকেন |

**উদাহরণ (Postman):**

- **Headers** ট্যাবে যান
- Key: `token`, Value: `{{buyerToken}}` (অথবা আপনার একটুয়াল টোকেন)

---

## Request Example

```http
GET {{baseurl}}/api/product/vendor/1
token: {{buyerToken}}
```

**Query parameters (পেজিনেশন):**

Laravel পেজিনেশন সাপোর্ট করে। পেজ নম্বর দিতে চাইলে:

| Parameter | Type   | Description      |
|-----------|--------|------------------|
| `page`    | integer| পেজ নম্বর (ডিফল্ট: 1) |

উদাহরণ: `GET {{baseurl}}/api/product/vendor/1?page=2`

---

## Response

### Success (২০০ OK)

**Body (JSON):**

```json
{
  "status": "success",
  "message": "Products found",
  "data": {
    "all": 3,
    "products": {
      "current_page": 1,
      "data": [
        {
          "id": 3,
          "name": "Camera",
          "description": "This is Camera",
          "regular_price": "3.00",
          "sell_price": "3.40",
          "image": "https://res.cloudinary.com/...",
          "vendor_id": 1,
          "category_id": 1,
          "color": [],
          "size": [],
          "category": { ... },
          "images": [
            {
              "id": 1,
              "image_path": "...",
              "product_id": 3
            }
          ]
        }
      ],
      "first_page_url": "http://...",
      "from": 1,
      "last_page": 1,
      "last_page_url": "http://...",
      "next_page_url": null,
      "path": "http://.../api/product/vendor/1",
      "per_page": 10,
      "prev_page_url": null,
      "to": 3,
      "total": 3
    }
  }
}
```

**ফিল্ড ব্যাখ্যা:**

| Field | Type   | Description |
|-------|--------|-------------|
| `status` | string | `"success"` অথবা `"failed"` |
| `message` | string | API মেসেজ (যেমন: `"Products found"`) |
| `data` | object | মূল ডাটা |
| `data.all` | integer | বর্তমান পেজের প্রোডাক্ট সংখ্যা |
| `data.products` | object | Laravel পেজিনেটেড অবজেক্ট |
| `data.products.current_page` | integer | বর্তমান পেজ নম্বর |
| `data.products.data` | array | প্রোডাক্ট লিস্ট |
| `data.products.per_page` | integer | পেজ প্রতি আইটেম (ডিফল্ট 10) |
| `data.products.total` | integer | মোট প্রোডাক্ট সংখ্যা |
| `data.products.last_page` | integer | শেষ পেজ নম্বর |

**প্রতিটি প্রোডাক্ট অবজেক্টে থাকতে পারে:**

| Field | Type   | Description |
|-------|--------|-------------|
| `id` | integer | প্রোডাক্ট ID |
| `name` | string | প্রোডাক্টের নাম |
| `description` | string | বিবরণ |
| `regular_price` | string | নিয়মিত দাম |
| `sell_price` | string | বিক্রয় দাম |
| `image` | string | মূল ইমেজ URL |
| `vendor_id` | integer | ভেন্ডর ID |
| `category_id` | integer | ক্যাটাগরি ID |
| `color` | array | রঙ লিস্ট |
| `size` | array | সাইজ লিস্ট |
| `category` | object | ক্যাটাগরি রিলেশন (যদি থাকে) |
| `images` | array | অতিরিক্ত ইমেজ লিস্ট (`id`, `image_path`, `product_id`) |

---

### No Products (২০০ OK)

যদি ওই ভেন্ডরের কোনো প্রোডাক্ট না থাকে:

```json
{
  "status": "success",
  "message": "You have no products",
  "data": []
}
```

---

### Error (৫০০)

সার্ভার এরর হলে:

```json
{
  "status": "failed",
  "message": "Something went wrong",
  "data": "Error detail message..."
}
```

---

## Summary

| Item | Value |
|------|--------|
| **Route** | `GET /api/product/vendor/{id}` |
| **Auth** | Header: `token` (buyer token) |
| **Controller** | `BuyerHomeController@vendorByProduct` |
| **Success message** | `"Products found"` |
| **Paginated** | হ্যাঁ, পেজ প্রতি ১০টি প্রোডাক্ট |
