# Screens where static text is not yet using language keys

(Auth screens excluded. Only: driver, buyer, vendor, transport, subscription, ranking, navbar, affiliate.)

---

## Driver (`lib/features/driver`)

| File | Static text examples |
|------|------------------------|
| `screen/driver_ontheway.dart` | 'Search order', 'Order ID', 'Loading...' |
| `screen/driver_order/screen/driver_order_details.dart` | 'Loading...' |
| `screen/driver_status/screen/driver_traking_screen.dart` | 'Cash Receive', 'Confirm Delivery', 'Cancel', 'Save', 'Loading...', 'Cash receive note...', 'Write note here...', 'Write why you cannot deliver...', 'Enter your Address...', 'Error', 'Success', 'Close', 'Confirm' |
| `screen/driver_status/screen/ee.dart` | 'Packed', 'Confirm Delivery', 'Cancel', 'Loading...', 'Add note', 'Write note here...', 'Cancel', 'Save', 'Error', 'Success', 'Close', 'Confirm', hintTexts |
| `widgets/bottom_sheet.dart` | 'Please enter your location' |
| `screen/home/screen/driver_home.dart` | 'Loading...', 'Authentication error', 'Retry', 'No authentication token available', "Keep going! You're doing great today.", 'Failed to load orders', 'No found data' |
| `screen/driver_order/screen/driver_order.dart` | 'Loading...', 'Search by Order ID' |

---

## Buyer (`lib/features/buyer`)

| File | Static text examples |
|------|------------------------|
| `screens/all_categori/screen/category_product_screen.dart` | 'Search vendors...', 'Loading...' |
| `screens/filter/screen/buyer_filtering.dart` | 'Loading categories...', 'Failed to load categories', 'No categories found', 'Please enter your location', 'Please select a category' |
| `screens/buyer_vendor_profile/screen/vendor_promotion_screen.dart` | 'No promotions yet', 'Retry', 'Copied', 'Done', 'Required', 'Error', 'Copy referral link', 'Copy deep link', hintTexts, 'Create referral link' |
| `screens/filter/screen/filter_product_screen.dart` | screenName: "Filter Products" |
| `screens/prement/*` | 'Preparing checkout...', 'Invoice failed', 'Payment URL not found', 'Payment not completed', 'Checkout failed', 'Name', 'Receiver Name', 'Contact info updated', 'Delivery charge', 'Own Pick up', 'Payment Method', 'Complete Payment' |
| `screens/product/product_details.dart` | 'Loading...', 'Chat open failed', 'Please select' |
| `screens/order/*` | 'Loading...' |
| `screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart` | 'Loading...', 'Unable to get user ID...', 'Invalid user ID...', 'Failed to open chat' |
| `screens/cart/screen/cart_screen.dart` | 'Loading...', 'Cannot remove this item', 'Cart item removed', 'Failed to update' |
| `screens/prement/data/prement_data.dart` | 'Card', 'G Pay', 'PayPal', 'Cash', 'Mobile' |
| `screens/prement/widget/show_shipping_address_sheet.dart` | 'Name', 'Receiver name', 'Address', 'Enter your address', 'Town / City', etc., 'Shipping address updated' |
| `screens/see_just_for_you_screen.dart` | 'Loading...', 'Error loading Just For You' |
| `screens/all_categori/screen/all_categori_screen.dart` | 'Loading...', 'Error' |
| `screens/review/review_screen.dart` | 'Loading...' |
| `screens/buyer_vendor_profile/screen/buyer_vendor_cetagory_screen.dart` | 'Loading...' |
| `widgets/custom_top_card.dart`, `custom_categories.dart` | 'Loading...' |

---

## Vendor (`lib/features/vendor`)

| File | Static text examples |
|------|------------------------|
| `screens/vendor_store_document_upload/screen/store_document_upload_screen.dart` | 'Error', 'Success', 'Camera', 'Gallery (Multiple)' |
| `screens/vendor_product_add_page/screen/product_add_page.dart` | screenName: "Profile Edite", 'Loading...', 'Error', 'Enter Product Title', 'No categories available', 'Select Category', 'Enter Product Description...', 'e.g. kg, piece, etc.', 'Success', 'Product Created Successfully', 'Current price', 'Previous price', 'Stock', 'Weight (kg)', 'Cover Image', 'Gallery Images', 'Enter terms and conditions (optional)', 'Validation Error', 'Camera', 'Gallery' |
| `screens/vendor_home/screen/vendor_home_screen.dart` | 'Loading...', 'Error', 'No products found', 'Reorder products', 'Delivery setting', 'Success', 'Error', 'Save', 'Camera', 'Gallery' |
| `screens/vendor_my_product_screen.dart/screen/_attribute_menu_sheet.dart` | 'Validation', 'Success', 'Error', 'Delete Attribute', 'Are you sure...', 'Cancel', 'Delete', 'Add your custom attribute' |
| `screens/vendor_my_product_screen.dart/screen/vendor_my_product_screen.dart` | 'Error', 'Add your\nProduct' |
| `screens/my_product_color/screen/my_product_color.dart` | 'Loading...', 'Pick new color', 'Cancel', 'Add', 'Delete color?', 'Are you sure you want to delete this color?', 'Update color', 'Save' |
| `screens/vendor_product_other_screen/screen/vendor_product_color_name.dart` | 'Pick a color', 'Close', 'Color Name Attribute' |
| `screens/vendor_delivery_setting/screen/vendor_delivery_setting_screen.dart` | 'Search by name', 'Success', 'Error', 'Info', 'All routes are already added.', 'Route added' |
| `screens/product_edit/screen/product_edit_screen.dart` | 'Success', 'Error' |
| `screens/vendor_asign_to_order_driver/logic/vendor_driver_prement_logic.dart` | 'Preparing checkout...', 'Invoice failed', 'Payment URL not found', 'Payment completed & order assigned successfully', 'Payment not completed', 'Checkout failed' |

---

## Transport (`lib/features/transport`)

| File | Static text examples |
|------|------------------------|
| `screens/my_booking/screen/transport_booking.dart` | 'Loading...', 'Failed to load', 'Prev', 'Next' |
| `screens/booking_confirm/transport_shipment_details_screen.dart` | 'Payment URL not found', 'Payment not completed', 'Failed to load' |
| `screens/driver/screen/driver_details_screen.dart` | 'Loading...', 'Failed to load' |
| `screens/driver/screen/transport_See_all_driver.dart` | 'Loading...', 'Retry', 'No drivers found' |
| `screens/add_card_screen.dart` | screenName: "Add Card" |
| `screens/ongoing_order_screen.dart` | 'Order #12345', 'Driver Rahim Hossain', 'July 24,2025', 'Dhanmondi, Dhaka', 'Agartala, India' |
| `screens/transport_cancelled.dart` | 'Order #12345', 'Driver Rahim Hossain', 'See details', etc. |
| `screens/driver/widget/transport_driver_input_data.dart` | 'Set drop location', 'Enter drop address', 'Success', 'Error' |
| `screens/home/screen/transport_home.dart` | 'Loading...' |
| `screens/driver/logic/transport_driver_perment_logic.dart` | 'Preparing checkout...', 'Invoice failed', 'Payment URL not found', 'Payment completed successfully', 'Payment not completed', 'Checkout failed' |

---

## Subscription (`lib/features/subscription`)

| File | Static text examples |
|------|------------------------|
| `screen/subscription_screen.dart` | screenName: 'Subscription', 'Please log in to pay', 'Subscription activated. Thank you!', 'Payment was cancelled or failed.', 'Pay' |
| `screen/subscription_payment_webview_screen.dart` | 'Retry', 'Close' |

---

## Ranking (`lib/features/ranking`)

| File | Static text examples |
|------|------------------------|
| `screen/ranking_screen.dart` | 'Could not load user type' |

---

## Navbar (`lib/features/navbar`)

| Note | Already uses BKeys (home, chat, settings, order, my_bookings). No changes needed. |

---

## Affiliate (`lib/features/affiliate`)

| File | Static text examples |
|------|------------------------|
| `screen/affiliate_screen.dart` | 'Approved', 'Error', 'Delete link', 'Are you sure you want to delete the link for...', 'Cancel', 'Delete', 'Deleted', 'Copied', 'Limit reached', 'Delete link?', 'Links', 'Clicks', 'Conversions', 'Revenue', 'Create link', 'Copy', 'Copy link', 'Approve', 'Done', 'Updated', hintTexts ('e.g. Summer campaign', 'Where or how you'll use this link', etc.), 'Create link', 'Save changes' |

---

## Keys added in `BKeys` (buyer_kay.dart)

The following keys were added so these screens can use `ref.t(BKeys.xxx)`:

- filter_products, add_card, subscription_title, prev, next, search_order, search_by_order_id  
- no_found_data, failed_to_load_orders, keep_going_great_today, no_authentication_token, authentication_error  
- cash_receive, confirm_delivery, add_note, write_note_here, cancel, close, confirm  
- cash_receive_note, write_why_cannot_deliver, enter_your_address, please_enter_location  
- profile_edit, no_products_found, no_categories_available, select_category, product_created_successfully  
- validation_error, current_price, previous_price, enter_stock_quantity, weight_in_kg  
- cover_image, gallery_images, stock, delete_attribute, are_you_sure_delete_attribute  
- delete_link, delete_link_confirm, approved, deleted, limit_reached, updated  
- links, conversions, create_link, copy_link, copy, approve, done, required_label  
- could_not_load_user_type, please_log_in_to_pay, subscription_activated_thank_you, payment_cancelled_or_failed  
- set_drop_location, enter_drop_address, no_drivers_found  
- pick_new_color, add, delete_color_confirm, are_you_sure_delete_color, update_color  
- pick_a_color, color_name_attribute, gallery_multiple, complete_payment  

Use these keys in the listed files with `ref.t(BKeys.key_name, fallback: 'Display text')` and add the same keys + translations in your backend.
