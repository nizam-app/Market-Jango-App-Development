# Billing screens – static text keys for backend

Use these keys for **Buyer Billing** and **Buyer Invoice Details** screens.  
Format: `'key' => "Display text",`

---

## Copy-paste block (PHP / backend style)

```php
// Buyer Billing Screen & Buyer Invoice Details Screen
'billing' => "Billing",
'no_invoices_yet' => "No invoices yet",
'invoice_details' => "Invoice details",
'invoice_not_found' => "Invoice not found",
'invoice_label' => "Invoice #",
'payable' => "Payable",
'date' => "Date",
'customer' => "Customer",
'payment_successful' => "Payment successful",
'cash_on_delivery' => "Cash on delivery",
'product_label' => "Product #",
'vendor_label' => "Vendor #",
'qty' => "Qty:",
'error_occurred' => "Something went wrong",
'loading' => "Loading...",
'total' => "Total",
'payment' => "Payment",
'status' => "Status",
'items' => "Items",
'retry' => "Retry",
```

---

## Key → Screen mapping

| Key | Screen | Usage |
|-----|--------|--------|
| `billing` | Buyer Billing | Page title |
| `no_invoices_yet` | Buyer Billing | Empty state when no invoices |
| `invoice_label` | Buyer Billing | Prefix for invoice number (e.g. "Invoice #" + id) |
| `loading` | Both | Loading indicator text |
| `error_occurred` | Both | Error state message |
| `invoice_details` | Invoice Details | Title prefix (e.g. "Invoice details #12") |
| `invoice_not_found` | Invoice Details | When invoice data is null |
| `total` | Invoice Details | Row label in header |
| `payable` | Invoice Details | Row label in header |
| `date` | Invoice Details | Row label in header |
| `customer` | Invoice Details | Row label in header |
| `payment` | Invoice Details | Row label in header |
| `payment_successful` | Invoice Details | Payment method label (FW) |
| `cash_on_delivery` | Invoice Details | Payment method label (OPU) |
| `status` | Invoice Details | Row label in header |
| `items` | Invoice Details | Section title for line items |
| `product_label` | Invoice Details | Fallback product name (e.g. "Product #" + id) |
| `vendor_label` | Invoice Details | Fallback vendor name (e.g. "Vendor #" + id) |
| `qty` | Invoice Details | Quantity prefix (e.g. "Qty: 2") |
| `retry` | (optional) | Retry button if you add one later |

---

## Alternative format (double-quote key)

If your backend expects double-quote keys:

```
"billing" => "Billing",
"no_invoices_yet" => "No invoices yet",
"invoice_details" => "Invoice details",
"invoice_not_found" => "Invoice not found",
"invoice_label" => "Invoice #",
"payable" => "Payable",
"date" => "Date",
"customer" => "Customer",
"payment_successful" => "Payment successful",
"cash_on_delivery" => "Cash on delivery",
"product_label" => "Product #",
"vendor_label" => "Vendor #",
"qty" => "Qty:",
"error_occurred" => "Something went wrong",
"loading" => "Loading...",
"total" => "Total",
"payment" => "Payment",
"status" => "Status",
"items" => "Items",
"retry" => "Retry",
```
