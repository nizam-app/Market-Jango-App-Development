Vendor app (store owner / manager assigns a driver)
Use the vendor assign endpoint (no Flutterwave on this path):

Method: POST
Path: /api/vendor/orders/{invoice_item_id}/assign-driver
(invoice_item_id = the order line id, same as elsewhere in vendor orders.)
Headers: Same as your other authenticated calls (tokenVerify — typically id, email, token, etc., as you already send).
Body (JSON): { "driver_id": <drivers.id> }
Optional helpers from the same area:

GET /api/vendor/drivers/available — list drivers
GET /api/vendor/orders/{item_id}/assignment — current assignment
POST /api/vendor/orders/{item_id}/unassign-driver — cancel assignment
These live under tokenVerify and, for assign/unassign, under moderatorAccess:Owner,Manager (see routes/api.php).

Note: There is still a legacy route POST /api/vendor/invoice/create/{driver_id}/{order_item_id} that goes through VendorHomePageController::vendorInvoice and is tied to the old “pay + assign” style flow. For “assign only, pay driver elsewhere,” the Flutter vendor app should use /vendor/orders/{item_id}/assign-driver, not that invoice route.

**Flutter:** The driver-list flow “Assign order” screen (`AssignToOrderDriver` → `startVendorAssignCheckout` in `lib/features/vendor/screens/vendor_asign_to_order_driver/logic/vendor_driver_prement_logic.dart`) calls `VendorOrderApi.assignDriverToOrderItem` → `POST …/vendor/orders/{invoice_item_id}/assign-driver` with JSON `{ "driver_id": … }`. It does **not** open a payment WebView; payment is handled outside this path if needed.

The API rejects assigns unless the line is **pending** or **processing** (see error: “Order must be in processing or pending state…”). The assign-order screen filters the list with `VendorOrderAssignRules.isPendingOrProcessingStatus` so users only pick eligible lines. Driver **name** is passed from the driver list (`AssignToOrderDriverArgs`) so the title and bottom button both say e.g. “Assign order to driver Murphy”, not only the numeric id.
