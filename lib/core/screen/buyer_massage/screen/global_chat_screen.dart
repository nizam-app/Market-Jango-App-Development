import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/vendor_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/buyer_massage/data/chat_history_data.dart';
import 'package:market_jango/core/screen/buyer_massage/logic/message_send_riverpod.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_model.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_offer_model.dart';
import 'package:market_jango/core/screen/buyer_massage/data/offer_product_repository.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/all_vendor_product_screen.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/create_offer_sheet.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:market_jango/core/screen/buyer_massage/widget/custom_textfromfield.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

class GlobalChatScreen extends ConsumerStatefulWidget {
  const GlobalChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    required this.partnerImage,
    required this.myUserId,
  });

  static const routeName = "/chatScreen";

  final int partnerId;
  final String partnerName;
  final String partnerImage;
  final int myUserId;

  @override
  ConsumerState<GlobalChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<GlobalChatScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    // Fetch history
    final history = ref.watch(chatHistoryStreamProvider(widget.partnerId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AllColor.black, size: 17.sp),
          onPressed: context.pop,
        ),
        title: Row(
          children: [
            CircleAvatar(
              child: FirstTimeShimmerImage(
                imageUrl: widget.partnerImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              widget.partnerName,
              style: theme.titleLarge?.copyWith(fontSize: 20.sp),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.videocam_outlined, size: 24.sp),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.call_outlined, size: 24.sp),
        //     onPressed: () {},
        //   ),
        // ],
        backgroundColor: AllColor.white,
        elevation: 1,
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (serverMessages) {
          final incoming = serverMessages.reversed.toList(); // newest first
          if (!_seeded) {
            _messages = incoming;
            _seeded = true;
          } else {
            // add only those ids we don't have yet (ignore local negative ids)
            final have = _messages
                .where((m) => m.id > 0)
                .map((m) => m.id)
                .toSet();
            for (final m in incoming) {
              if (!have.contains(m.id)) {
                _messages.insert(0, m);
              }
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    final mine = m.senderId == widget.myUserId;
                    final isLocal = m.id < 0 && m.image == 'local';
                    final file = isLocal ? _localImageMap[m.id] : null;

                    return _MessageRow(
                      message: m,
                      text:
                          (m.image != null &&
                              m.image!.isNotEmpty &&
                              m.image != 'local')
                          ? null
                          : (m.message ?? ''),
                      imageUrl:
                          (!isLocal &&
                              (m.image ?? '').isNotEmpty &&
                              m.image != 'local')
                          ? m.image
                          : null,
                      localImage: file,
                      uploading: isLocal, // show spinner on local images
                      time: _prettyTime(m.createdAt),
                      isSender: mine,
                      myUserId: widget.myUserId,
                      partnerId: widget.partnerId,
                      onOfferAccepted: (offerId) {
                        // Refresh chat history after offer acceptance
                        ref.invalidate(chatHistoryStreamProvider(widget.partnerId));
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _composer(),
              ),
            ],
          );
        },
      ),
    );
  }

  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<ChatMessage> _messages = [];
  bool _seeded = false;

  // temp local image map: tempId -> File
  final Map<int, File> _localImageMap = {};

  @override
  void initState() {
    super.initState();
    debugPrint(
      "CHAT args → partnerId=${widget.partnerId}, myUserId=${widget.myUserId}, name=${widget.partnerName}, image = ${widget.partnerImage}",
    );
    // Listen to text changes to update Send button state
    _textController.addListener(() {
      setState(() {}); // Rebuild to update Send button state
    });
  }
  
  void _askImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        // Use Consumer to ensure user type is properly watched/loaded
        return Consumer(
          builder: (context, ref, child) {
            final userTypeAsync = ref.watch(getUserTypeProvider);
            final isVendor = userTypeAsync.value?.toLowerCase() == 'vendor';
            
            return SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Camera'),
                    onTap: () {
                      Navigator.pop(context);
                      pickMainImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      pickMainImage(ImageSource.gallery);
                    },
                  ),
                  if (isVendor) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text('Send product offer'),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToProductOffer();
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToProductOffer() async {
    final selectedProduct = await Navigator.of(context).push<VendorProduct>(
      MaterialPageRoute(
        builder: (ctx) => const AllVendorProductScreen(),
        settings: RouteSettings(arguments: widget.partnerId),
      ),
    );

    if (selectedProduct != null && mounted) {
      // Show the offer creation sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateOfferSheet(
          product: selectedProduct,
          receiverId: widget.partnerId,
          onOfferCreated: (chatMessage) {
            // Refresh chat history to show the new offer message
            ref.invalidate(chatHistoryStreamProvider(widget.partnerId));
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offer sent successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      );
    }
  }

  Future<void> pickMainImage(ImageSource source) async {
    final x = await _picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;

    final file = File(x.path);
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final nowIso = DateTime.now().toIso8601String();

    setState(() {
      _localImageMap[tempId] = file;
      _messages.insert(
        0,
        ChatMessage(
          id: tempId, // negative => local/temporary
          senderId: widget.myUserId,
          receiverId: widget.partnerId,
          message: '', // no text
          image: 'local', // marker
          publicId: null,
          isRead: 0,
          replyTo: null,
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
    });

    // If there's no text in the input, send the image immediately
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _sendMessage();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    final t = text.trim();
    // Check if there's something to send (text or images)
    if (t.isEmpty && _localImageMap.isEmpty) return;
    
    // If there are images, send everything together
    if (_localImageMap.isNotEmpty) {
      _sendMessage();
    } else {
      // Only text, send immediately
      _textController.clear();
      _sendMessage();
    }
  }

  /// Check if there's something to send (text or images)
  bool _hasContentToSend() {
    final text = _textController.text.trim();
    return text.isNotEmpty || _localImageMap.isNotEmpty;
  }

  /// Send message (text and/or images)
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    final localFiles = _localImageMap.values.toList();

    // If nothing to send, return
    if (text.isEmpty && localFiles.isEmpty) return;

    // Optimistic UI update for text (if any)
    if (text.isNotEmpty) {
      final nowIso = DateTime.now().toIso8601String();
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            id: -DateTime.now().millisecondsSinceEpoch,
            senderId: widget.myUserId,
            receiverId: widget.partnerId,
            message: text,
            image: null,
            publicId: null,
            isRead: 0,
            replyTo: null,
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );
      });
    }

    // Clear input box
    _textController.clear();

    // Call API
    final sent = await ref.read(chatSendProvider.notifier).send(
          partnerId: widget.partnerId,
          message: text.isEmpty ? null : text,
          images: localFiles.isEmpty ? null : localFiles,
        );

    if (sent != null) {
      // Remove all temp (negative id) bubbles we just added
      setState(() {
        _messages.removeWhere((m) => m.id < 0);
        _localImageMap.clear();
      });
      // Pull fresh history so server URLs come in
      ref.invalidate(chatHistoryStreamProvider(widget.partnerId));
    } else {
      // Restore text if send failed
      if (text.isNotEmpty) {
        _textController.text = text;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message send failed')),
        );
      }
    }
  }

  String _prettyTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return '';
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $ap';
    } catch (_) {
      return '';
    }
  }

  Widget _composer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        height: 60.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AllColor.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: AllColor.black54, size: 24.sp),
                onPressed: _askImageSource,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomTextFromField(
                controller: _textController,
                hintText: ref.t(VKeys.typeAMessage),
                onFieldSubmitted: _handleSubmitted,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: AllColor.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: _hasContentToSend()
                      ? AllColor.blue
                      : AllColor.grey.shade400,
                  size: 24.sp,
                ),
                onPressed: _hasContentToSend() ? _sendMessage : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Simple message bubble row (keeps your style) ---------- */

class _MessageRow extends ConsumerWidget {
  const _MessageRow({
    required this.message,
    required this.time,
    required this.isSender,
    required this.myUserId,
    required this.partnerId,
    this.text,
    this.imageUrl,
    this.localImage, // <— File? for local preview
    this.uploading = false,
    this.onOfferAccepted,
  });

  final ChatMessage message;
  final String? text;
  final String time;
  final bool isSender;
  final int myUserId;
  final int partnerId;
  final String? imageUrl; // server url
  final File? localImage; // local file (optimistic)
  final bool uploading;
  final Function(int)? onOfferAccepted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if this is an offer message
    if (message.isOfferMessage && message.offer != null) {
      return _OfferCard(
        offer: message.offer!,
        isSender: isSender,
        time: time,
        myUserId: myUserId,
        partnerId: partnerId,
        onOfferAccepted: onOfferAccepted,
      );
    }

    final bubbleColor = isSender
        ? AllColor.blue.withOpacity(.2)
        : AllColor.grey.shade100;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(16.r),
      topRight: Radius.circular(16.r),
      bottomLeft: Radius.circular(isSender ? 16.r : 0),
      bottomRight: Radius.circular(isSender ? 0 : 16.r),
    );

    final hasImage = (localImage != null) || ((imageUrl ?? '').isNotEmpty);

    Widget body;
    if (hasImage) {
      body = Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: SizedBox(
              width: 220.w, // bubble width for image
              child: localImage != null
                  ? Image.file(localImage!, fit: BoxFit.cover)
                  : FirstTimeShimmerImage(
                      imageUrl: imageUrl!,
                      width: 220.w,
                      height: 140.h,
                      fit: BoxFit.cover,
                      borderRadius: radius,
                    ),
            ),
          ),
          if (uploading)
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                ),
                height: 140.h,
                width: 220.w,
              ),
            ),
        ],
      );
    } else {
      body = Text(
        text ?? '',
        style: TextStyle(fontSize: 15.sp, color: AllColor.black87),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isSender
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isSender) SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  constraints: hasImage
                      ? const BoxConstraints() // image sets own width
                      : BoxConstraints(maxWidth: 0.75.sw),
                  padding: hasImage
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: body,
                ),
              ),
              if (isSender) SizedBox(width: 8.w),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h,
              left: isSender ? 0 : 16.w,
              right: isSender ? 16.w : 0,
            ),
            child: Text(
              time,
              style: TextStyle(color: AllColor.grey, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- Offer Card Widget ---------- */

class _OfferCard extends ConsumerStatefulWidget {
  const _OfferCard({
    required this.offer,
    required this.isSender,
    required this.time,
    required this.myUserId,
    required this.partnerId,
    this.onOfferAccepted,
  });

  final ChatOffer offer;
  final bool isSender;
  final String time;
  final int myUserId;
  final int partnerId;
  final Function(int)? onOfferAccepted;

  @override
  ConsumerState<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends ConsumerState<_OfferCard> {
  bool _isAccepting = false;
  bool _isAccepted = false;

  @override
  void initState() {
    super.initState();
    _isAccepted = widget.offer.isAccepted == 1;
  }

  Future<void> _acceptOffer() async {
    if (_isAccepting || _isAccepted) return;

    setState(() => _isAccepting = true);

    try {
      final repository = OfferProductRepository();
      await repository.acceptOffer(widget.offer.id);

      setState(() {
        _isAccepting = false;
        _isAccepted = true;
      });

      if (widget.onOfferAccepted != null) {
        widget.onOfferAccepted!(widget.offer.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer added to cart')),
        );
      }
    } catch (e) {
      setState(() => _isAccepting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept offer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isSender
        ? AllColor.blue.withOpacity(.2)
        : AllColor.grey.shade100;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(16.r),
      topRight: Radius.circular(16.r),
      bottomLeft: Radius.circular(widget.isSender ? 16.r : 0),
      bottomRight: Radius.circular(widget.isSender ? 0 : 16.r),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        crossAxisAlignment: widget.isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isSender
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isSender) SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 0.75.sw),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image and name
                      Row(
                        children: [
                          if (widget.offer.productImage != null &&
                              widget.offer.productImage!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                widget.offer.productImage!,
                                width: 60.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60.w,
                                  height: 60.h,
                                  color: AllColor.grey200,
                                  child: Icon(Icons.image, size: 30.sp),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 60.w,
                              height: 60.h,
                              color: AllColor.grey200,
                              child: Icon(Icons.image, size: 30.sp),
                            ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.offer.productName ?? 'Product',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AllColor.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Special Offer',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AllColor.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(height: 1),
                      SizedBox(height: 12.h),
                      // Offer details
                      _OfferDetailRow(
                        label: 'Price',
                        value: '৳${widget.offer.salePrice}',
                      ),
                      SizedBox(height: 8.h),
                      _OfferDetailRow(
                        label: 'Quantity',
                        value: '${widget.offer.quantity}',
                      ),
                      SizedBox(height: 8.h),
                      _OfferDetailRow(
                        label: 'Delivery',
                        value: '৳${widget.offer.deliveryCharge}',
                      ),
                      if (widget.offer.color != null &&
                          widget.offer.color!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _OfferDetailRow(
                          label: 'Color',
                          value: widget.offer.color!,
                        ),
                      ],
                      if (widget.offer.size != null &&
                          widget.offer.size!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _OfferDetailRow(
                          label: 'Size',
                          value: widget.offer.size!,
                        ),
                      ],
                      SizedBox(height: 12.h),
                      // Accept button (only for buyer, not sender)
                      if (!widget.isSender && !_isAccepted)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isAccepting ? null : _acceptOffer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AllColor.blue,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: _isAccepting
                                ? SizedBox(
                                    height: 18.h,
                                    width: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Accept Offer',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AllColor.white,
                                    ),
                                  ),
                          ),
                        ),
                      if (!widget.isSender && _isAccepted)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AllColor.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '✓ Accepted',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AllColor.green,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.isSender) SizedBox(width: 8.w),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h,
              left: widget.isSender ? 0 : 16.w,
              right: widget.isSender ? 16.w : 0,
            ),
            child: Text(
              widget.time,
              style: TextStyle(color: AllColor.grey, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferDetailRow extends StatelessWidget {
  const _OfferDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AllColor.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.black87,
          ),
        ),
      ],
    );
  }
}
