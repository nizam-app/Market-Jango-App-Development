# ল্যাঙ্গুয়েজ চেঞ্জ — ট্রেন্সলেশন কী ডকумент (Buyer / Vendor / Driver / Transport)

এই ডকументে যে **স্ট্রিংগুলো ল্যাঙ্গুয়েজ পরিবর্তনের জন্য ব্যাকএন্ড/ট্রেন্সলেটরকে ইনপুট দিতে হবে**, সেগুলো এক জায়গায় গোষ্ঠীভাবে দেওয়া হয়েছে। অ্যাপে মূল **ক্লাস টোকেন** ও **টি স্টম স্ট্রিং স্লাগ** এর ম্যাপ করা আছে।

---

## উৎস ও বিকল্প

| উপাদান | পাথ |
|--------|-----|
| কোয়ান্ট সহ বেশিরভাগ টেক্সট কী (`BKeys`) | `lib/core/localization/Keys/buyer_kay.dart` |
| ছোট সেট ও আংশিক টেক্সট (`VKeys`) — আলাদা স্লাগ ডিজাইন | `lib/core/localization/Keys/vendor_kay.dart` |
| ট্রেন্সলেশন লোড (API থেকে `{ "key": "translated" }`) | `lib/core/localization/translation_providers.dart` |
| ব্যবহার UI-তে | `ref.t(BKeys.xyz)` বা `ref.t(VKeys.xyz)` এর মাধ্যমে (দেখুন `lib/core/localization/tr.dart`) |

**API:** `GET …/translations` — `CommonAPIController.translations` (`lib/core/constants/api_control/common_api.dart`)। টোকেন থাকলে হেডারে `token` পাঠাতে পারে; বাকি ভাষা নির্ধারণ ব্যাকএন্ডের উপর।

---

## ব্যাখ্যা: ট্যাগ এর অর্থ

| ট্যাগ | অর্থ |
|--------|------|
| **C** | সাধারণ — একাধিক রোলের স্ক্রিনে (লগইন, প্রোফাইল ভিত্তিমান, এরর/লোডিং ইত্যাদি)। |
| **B** | বায়ার-সেন্ট্রিক (হোম, কার্ট, চেকআউট, বাইয়ার ইনভয়েস…)। |
| **V** | ভেন্ডর প্যানেল (স্টোর, শেয়ার প্লাটফর্ম, প্রডাক্ট ও ক্যাটাগরি UI ইত্যাদি)। |
| **D** | ড্রাইভার (হোম স্ট্যাটস, ডেলিভারি অর্ডার, ট্র্যাকিং…)। |
| **T** | ট্রান্সপোর্ট (ড্রাইভার খোঁজা, শিপমেন্ট, বুকিং…)। |

একটি কী একাধিক ট্যাগে থাকতে পারে (যেমন `billing` — বাইয়ার ও ট্রান্সপোর্ট আলাদা স্ক্রিনে)।

---

## ১। সাধারণ (C — সব/বেশিরভাগ রোল)

লগইন, সাইনআপ, রিকভার পাসওয়ার্ড, ইউজার টাইপ নির্বাচন, নাম·ফোন·ইমেল ভেরিফিকেশন, অভিনন্দন, খুচরা লেভেল এরর/পুনঃচেষ্টা, ভাষা/প্রোফাইল খুচরা টেক্সট।

| ট্রেন্সলেশন স্লাগ (ব্যাকএন্ড কী) | Dart নাম (`BKeys.…`) |
|-----------------------------------|----------------------|
| `marketplace_slogan` | `marketplaceSlogan` |
| `login` | `login` |
| `sign_up` | `signUp` |
| `trouble_signing_in` | `troubleSigningIn` |
| `login_here` | `loginHere` |
| `welcome_back` | `welcomeBack` |
| `email_or_phone` | `emailOrPhone` |
| `password` | `password` |
| `forgot_password` | `forgotPassword` |
| `dont_have_account` | `dontHaveAccount` |
| `recover_password` | `recoverPassword` |
| `recover_instruction` | `recoverInstruction` |
| `email` | `email` |
| `submit` | `submit` |
| `verification` | `verification` |
| `verification_sent` | `verificationSent` |
| `next` | `next` |
| `didnt_receive_code` | `didntReceiveCode` |
| `resend` | `resend` |
| `create_new_password` | `createNewPassword` |
| `new_password_instruction` | `newPasswordInstruction` |
| `new_password_label` | `newPasswordLabel` |
| `confirm_password` | `confirmPassword` |
| `confirm` | `confirm` |
| `user_type_selection` | `userTypeSelection` |
| `choose_one` | `chooseOne` |
| `buyer` | `buyer` |
| `vendor` | `vendor` |
| `driver` | `driver` |
| `transport` | `transport` |
| `name_prompt` | `namePrompt` |
| `enter_name` | `enterName` |
| `name_note` | `nameNote` |
| `phone_prompt` | `phonePrompt` |
| `phone_instruction` | `phoneInstruction` |
| `code_prompt` | `codePrompt` |
| `your_email` | `yourEmail` |
| `verify_email` | `verifyEmail` |
| `congratulation` | `congratulation` |
| `congratulations` | `congratulations` |
| `back_home` | `backHome` |
| `my_profile` | `myProfile` |
| `language` | `language` |
| `log_out` | `logOut` |
| `your_name` | `yourName` |
| `phone` | `phone` |
| `gender` | `gender` |
| `female` | `female` |
| `about` | `about` |
| `age` | `age` |
| `location` | `location` |
| `settings` | `settings` |
| `save` | `save` |
| `reviews` | `reviews` |
| `loading` | `loading` |
| `error` | `error` |
| `no_authentication_token` | `no_authentication_token` |
| `authentication_error` | `authentication_error` |
| `retry` | `retry` |
| `notifications` | `notifications` |
| `messages` | `messages` |
| `something_went_wrong` | `something_went_wrong` |
| `error_occurred` | `errorOccurred` |

---

## ২। বায়ার (B)

হোম ক্যাটালগ, সার্চ·ফিল্টার, ভেন্ডার প্রোফাইল খুচরো, কার্ট ও চেকআউট, বাইয়ার অর্ডার/বিলিং ও রিভিউ, নেভ খুচরা (`home`, `cart`, ইত্যাদি)।

| ট্রেন্সলেশন স্লাগ | Dart নাম |
|-------------------|-----------|
| `search_product` | `searchProduct` |
| `categories` | `categories` |
| `see_all` | `seeAll` |
| `top_products` | `topProducts` |
| `new_items` | `newItems` |
| `just_for_you` | `justForYou` |
| `home` | `home` |
| `cart` | `cart` |
| `account` | `account` |
| `chat` | `chat` |
| `your_country` | `yourCountry` |
| `enter_location` | `enterLocation` |
| `search_location` | `searchLocation` |
| `search` | `search` |
| `search_vendor` | `searchVendor` |
| `fashion` | `fashion` |
| `open_time` | `openTime` |
| `am` | `am` |
| `pm` | `pm` |
| `popular` | `popular` |
| `total` | `total` |
| `checkout` | `checkout` |
| `payment` | `payment` |
| `delivery_charge` | `deliveryCharge` |
| `pic_up` | `picUp` |
| `payment_method` | `paymentMethod` |
| `pay` | `pay` |
| `shipping_address` | `shippingAddress` |
| `address` | `address` |
| `town_city` | `townCity` |
| `post_code` | `postCode` |
| `save_changes` | `saveChanges` |
| `my_orders` | `myOrders` |
| `order_history` | `orderHistory` |
| `billing` | `billing` |
| `no_invoices_yet` | `noInvoicesYet` |
| `invoice_details` | `invoiceDetails` |
| `invoice_not_found` | `invoiceNotFound` |
| `invoice_label` | `invoiceLabel` |
| `invoice_vendor_block` | `invoiceVendorBlock` |
| `payable` | `payable` |
| `date` | `date` |
| `customer` | `customer` |
| `payment_successful` | `paymentSuccessful` |
| `cash_on_delivery` | `cashOnDelivery` |
| `product_label` | `productLabel` |
| `vendor_label` | `vendorLabel` |
| `qty` | `qty` |
| `number_of_products` | `numberOfProducts` |
| `order_number` | `orderNumber` |
| `product_name` | `productName` |
| `cost` | `cost` |
| `tax` | `tax` |
| `platform_fees` | `platformFees` |
| `total_fees` | `totalFees` |
| `download` | `download` |
| `invoice_copied` | `invoiceCopied` |
| `to_receive` | `toReceive` |
| `items` | `items` |
| `chat_now` | `chatNow` |
| `delivery_not_successful` | `deliveryNotSuccessful` |
| `what_should_i_do` | `whatShouldIDo` |
| `dont_worry` | `dontWorry` |
| `review` | `review` |
| `add_your_review` | `addYourReview` |
| `filter_products` | `filter_products` |
| `please_add_the_cart_product` | `please_add_the_cart_product` |
| `updating` | `updating` |
| `shippingAddressUpdated` | `shipping_address_updated` |
| `no_completed_orders_yet` | `no_completed_orders_yet` |
| `buy_now` | `buyNow` |
| `no_top_products` | `no_top_products` |
| `no_popular_products_found` | `no_popular_products_found` |
| `all_categories` | `all_categories` |
| `trend_loop` | `trend_Loop` |
| `no_vendors` | `no_vendors` |
| `contactInformation` | `contactInformation` |
| `specifications` | `specifications` |
| `color` | `color` |
| `sizes` | `sizes` |

---

## ৩। ভেন্ডর (V)

ভেন্ডর স্টোর তৈরি, অ্যানালিটিক্স, অর্ডার ও প্রডাক্ট/ক্যাটাগরি/কালার টুলস।

| ট্রেন্সলেশন স্লাগ | Dart নাম |
|-------------------|-----------|
| `create_store` | `createStore` |
| `get_started` | `getStarted` |
| `choose_country` | `chooseCountry` |
| `business_name` | `businessName` |
| `business_type` | `businessType` |
| `full_address` | `fullAddress` |
| `upload_documents` | `uploadDocuments` |
| `upload_images` | `uploadImages` |
| `wait_for_confirmation` | `waitForConfirmation` |
| `account_under_review` | `accountUnderReview` |
| `close_app` | `closeApp` |
| `add_your_product` | `addYourProduct` |
| `order` | `order` |
| `pending` | `pending` |
| `assigned_order` | `assignedOrder` |
| `completed` | `completed` |
| `store_performance` | `storePerformance` |
| `last_30_days_overview` | `last30DaysOverview` |
| `revenue` | `revenue` |
| `clicks` | `clicks` |
| `conversion_rate` | `conversionRate` |
| `sales` | `sales` |
| `previous_period` | `previousPeriod` |
| `top_selling_products` | `topSellingProducts` |
| `product` | `product` |
| `units` | `units` |
| `revenues` | `revenues` |
| `mon` … `sun` | `mon` … `sun` |
| `search_orders` | `searchOrders` |
| `assigned_to_order` | `assignedToOrder` |
| `search_your_transporter` | `searchYourTransporter` |
| `assign_order_to_driver` | `assignOrderToDriver` |
| `online` | `online` |
| `my_product` | `my_product` |
| `my_Settings` | `my_settings` |
| `color_attribute ` *(ট্রেলিং স্পেস)* | `color_attribute` |
| `category_title` | `category_title` |
| `enter_your_title_here` | `enter_your_title_here` |
| `category_description ` | `category_description` |
| `upload_category_images` | `upload_category_images` |
| `save_category` | `save_category` |
| `products_list ` | `products_list` |
| `size_attribute` | `size_attribute` |
| `name` | `name` |
| `value ` | `value` |
| `product_title` | `product_title` |
| `track_shipments` | `track_shipments` |
| `profile_edit` | `profile_edit` |
| `no_products_found` | `no_products_found` |
| `no_categories_available` | `no_categories_available` |
| `select_category` | `select_category` |
| `product_created_successfully` | `product_created_successfully` |
| `validation_error` | `validation_error` |
| `current_price` | `current_price` |
| `previous_price` | `previous_price` |
| `enter_stock_quantity` | `enter_stock_quantity` |
| `weight_in_kg` | `weight_in_kg` |
| `cover_image` | `cover_image` |
| `gallery_images` | `gallery_images` |
| `stock` | `stock` |
| `delete_attribute` | `delete_attribute` |
| `are_you_sure_delete_attribute` | `are_you_sure_delete_attribute` |
| `links` | `links` |
| `conversions` | `conversions` |
| `create_link` | `create_link` |
| `copy_link` | `copy_link` |
| `copy` | `copy` |
| `approve` | `approve` |
| `approved` | `approved` |
| `deleted` | `deleted` |
| `updated` | `updated` |
| `delete_link` | `delete_link` |
| `delete_link_confirm` | `delete_link_confirm` |
| `limit_reached` | `limit_reached` |
| `subscription_title` | `subscription_title` |
| `required_label` | `required_label` |
| *(আরও affiliate/subscription খুচরো)* — | `please_log_in_to_pay`, `subscription_activated_thank_you`, `payment_cancelled_or_failed`, `complete_payment`, `add_card`, … নিচে “যৌথ” টেবিলে |

---

## ৪। ড্রাইভার (D)

ড্রাইভার অনবোর্ডিং (গাড়ি ও লাইসেন্স টেক্সট), হোম স্ট্যাটস ও অর্ডার ফ্লো।

| ট্রেন্সলেশন স্লাগ | Dart নাম |
|-------------------|-----------|
| `car_information` | `carInformation` |
| `car_get_started` | `carGetStarted` |
| `car_brand_name` | `carBrandName` |
| `car_model` | `carModel` |
| `car_location` | `carLocation` |
| `driving_route` | `drivingRoute` |
| `price` | `price` |
| `upload_license_documents` | `uploadLicenseDocuments` |
| `upload_car_images` | `uploadCarImages` |
| `new_order` | `new_order` |
| `total_active_order` | `total_active_order` |
| `picked` | `picked` |
| `pending_deliveries` | `pending_deliveries` |
| `delivered_today` | `delivered_today` |
| `see_details` | `see_details` |
| `track_order` | `track_order` |
| `bottomName` | `bottomName` |
| `pickup_address` | `pickup_address` |
| `drop_off_address =` ⚠ টাইপো ফিক্স সুপারিশ | `drop_off_address` |
| `customer_details` | `customer_details` |
| `message_now` | `message_now` |
| `start_dlivery` ⚠ টাইপো | `start_delivery` |
| `pick_up_location` | `pick_up_location` |
| `destination` | `destination` |
| `delivered` | `delivered` |
| `enter_your_current_location` | `enter_your_current_location` |
| `cancelled` | `cancelled` |
| `search_order` | `search_order` |
| `search_by_order_id` | `search_by_order_id` |
| `failed_to_load_orders` | `failed_to_load_orders` |
| `no_found_data` | `no_found_data` |
| `failed_to_load_stats` | `failed_to_load_stats` |
| `keep_going_great_today` | `keep_going_great_today` |
| `cash_receive` | `cash_receive` |
| `confirm_delivery` | `confirm_delivery` |
| `add_note` | `add_note` |
| `write_note_here` | `write_note_here` |
| `cancel` | `cancel` |
| `close` | `close` |
| `cash_receive_note` | `cash_receive_note` |
| `write_why_cannot_deliver` | `write_why_cannot_deliver` |
| `enter_your_address` | `enter_your_address` |
| `please_enter_location` | `please_enter_location` |
| `t_shirt` | `t_shirt` |
| `no_data` | `no_data` |

---

## ৫। ট্রান্সপোর্ট (T)

খোলা শিপমেন্ট ড্রাইভার সার্চ বুকিং, প্যাকেজ ডিটেলস ও বিলিং।

| ট্রেন্সলেশন স্লাগ | Dart নাম |
|-------------------|-----------|
| `hello` | `hello` |
| `find_your_driver` | `find_your_driver` |
| `search_by_vendor_name` | `search_by_vendor_name` |
| `or` | `or` |
| `transport_type_motorcycle` | `transport_type_motorcycle` |
| `transport_type_car` | `transport_type_car` |
| `transport_type_air` | `transport_type_air` |
| `transport_type_water` | `transport_type_water` |
| `transport_type` | `transport_type` |
| `transport_type_all` | `transport_type_all` |
| `failed_to_load_drivers` | `failed_to_load_drivers` |
| `No_drivers_available` | `no_drivers_available` |
| `assigned_driver` | `assigned_driver` |
| `select_driver` | `select_driver` |
| `no_drivers_found` | `no_drivers_found` |
| `my_bookings` | `my_bookings` |
| `shipment_list` | `shipment_list` |
| `shipment_tab_all` | `shipment_tab_all` |
| `shipment_tab_on_the_way` | `shipment_tab_on_the_way` |
| `shipment_tab_completed` | `shipment_tab_completed` |
| `prev` | `prev` |
| `my_package_details` | `my_package_details` |
| `create_package` | `create_package` |
| `create_shipment` | `create_shipment` |
| `length` | `length` |
| `width` | `width` |
| `height` | `height` |
| `number_of_pieces` | `number_of_pieces` |
| `weight_kg` | `weight_kg` |
| `pickup_contact_details` | `pickup_contact_details` |
| `building_shop_number_name` | `building_shop_number_name` |
| `phone_number` | `phone_number` |
| `remove` | `remove` |
| `add_packages` | `add_packages` |
| `totals` | `totals` |
| `total_packages` | `total_packages` |
| `total_weight_kg` | `total_weight_kg` |
| `total_value_of_goods` | `total_value_of_goods` |
| `currency` | `currency` |
| `amount` | `amount` |
| `message_to_driver` | `message_to_driver` |
| `customer_note` | `customer_note` |
| `special_instruction` | `special_instruction` |
| `driver_information ` *(ট্রেলিং স্পেস)* | `driver_information` |
| `shipment_details` | `shipment_details` |
| `origin` | `origin` |
| `status` | `status` |
| `id` | `id` |
| `set_drop_location` | `set_drop_location` |
| `please_enter_drop_address` | `please_enter_drop_address` |
| `please_select_drop_location` | `please_select_drop_location` |
| `enter_drop_address` | `enter_drop_address` |
| `success` | `success` |
| `location_selected_successfully` | `location_selected_successfully` |

---

## ৬। যৌথ / মাল্টি-রোল UI (সাবস্ক্রিপশন, অ্যাফিলিয়েট, আরও)

বাইয়ার/ভেন্ডর/ট্রান্সপোর্ট ফিচার স্ক্রিনে ম শেয়ার।

| ট্রেন্সলেশন স্লাগ | Dart নাম |
|-------------------|-----------|
| `could_not_load_user_type` | `could_not_load_user_type` |
| `please_log_in_to_pay` | `please_log_in_to_pay` |
| `subscription_activated_thank_you` | `subscription_activated_thank_you` |
| `payment_cancelled_or_failed` | `payment_cancelled_or_failed` |
| `add_card` | `add_card` |
| `complete_payment` | `complete_payment` |
| — | `pick_new_color`, `add`, `delete_color_confirm`, `are_you_sure_delete_color`, `update_color`, `pick_a_color`, `color_name_attribute`, `gallery_multiple` |
| *(অ্যানালিটিকস/লিঙ্ক উপরে Vendor টেবিলে)* |

---

## ৭। `VKeys` — আলাদা স্লাগ ডিজাইন (ভেন্ডর UI এর অংশ)

ফাইল: `lib/core/localization/Keys/vendor_kay.dart` — এখানে ডান পাশের স্ট্রিং **একই ডিভাইডার হতে পারেনা** বা ব্যাকএন্ডে আলাদা ম্যাপিং থাকতে পারে। ট্রেন্সলেটরকে এই পুরো টেক্সটটাই দিন।

| Dart নাম (`VKeys.…`) | ডিফল্ট/স্লাগ স্ট্রিং |
|----------------------|----------------------|
| `home` | `Home` |
| `chat` | `Chat` |
| `notification` | `Notification` |
| `driver` | `Driver` |
| `settings` | `Settings` |
| `searchProducts` | `Search products...` |
| `messages` | `Messages` |
| `loding` | `Loading...` |
| `typeAMessage` | `Type a message...` |
| `notifications` | `Notifications` |
| `thereAreNoNotificationsNow` | `There are no notifications now.` |

---

## নোট: কোডে থাকা স্লাগ টাইপোগুলো ⚠️

এগুলো ট্রেন্সলেটরকে ফিক্স করতে বলুন **একই স্লাগ থাকুক** (যাতে অনুবাদ মিস না হয়), অথবা ব্যাকএন্ডে আਲাদা সংশোধন:

- `'drop_off_address ='` — ড্রপ অ্যাড্রেস টাইপো
- `'start_dlivery'` — ডেলিভারি টাইপো
- ট্রেলিং স্পেস: `'color_attribute '`, `'category_description '`, `'driver_information '` ইত্যাদি

সম্পূর্ণ খসড়া খুচরো মিল এ **`buyer_kay.dart` লাইন ৩–০৪০২** মাস্টার লিস্ট হিসাবে ধরা যেতে পারে; এই ডকументটি রোল ভিত্তিক কাজের ওয়ার্কশিট।
