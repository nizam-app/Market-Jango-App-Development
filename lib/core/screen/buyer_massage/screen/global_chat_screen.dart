import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/data/chat_history_data.dart';
import 'package:market_jango/core/screen/buyer_massage/logic/message_send_riverpod.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_model.dart';
import 'package:market_jango/core/screen/buyer_massage/widget/custom_textfromfield.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
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
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
            CircleAvatar(backgroundImage: NetworkImage(widget.partnerImage)),
            SizedBox(width: 10.w),
            Text(
              widget.partnerName,
              style: theme.titleLarge?.copyWith(fontSize: 20.sp),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined, size: 24.sp),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, size: 24.sp),
            onPressed: () {},
          ),
        ],
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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _textController.clear();

    // Optimistic add (send API can be added later)
    final nowIso = DateTime.now().toIso8601String();
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          id: -DateTime.now().millisecondsSinceEpoch, // temp id
          senderId: widget.myUserId,
          receiverId: widget.partnerId,
          message: t,
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
                hintText: "Type a message...",
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
                icon: Icon(Icons.send, color: AllColor.black54, size: 24.sp),
                onPressed: () async {
                  final text = _textController.text.trim();
                  // collect local images (temp ids)
                  final localFiles = _localImageMap.values.toList();

                  // optimistic text (if any)
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

                  // clear input box for instant feel
                  _textController.clear();

                  // call API (existing provider)
                  final sent = await ref
                      .read(chatSendProvider.notifier)
                      .send(
                        partnerId: widget.partnerId,
                        message: text.isEmpty ? null : text,
                        images: localFiles, // send all local images
                      );

                  if (sent != null) {
                    // remove all temp (negative id) bubbles we just added
                    setState(() {
                      _messages.removeWhere((m) => m.id < 0);
                      _localImageMap.clear();
                    });
                    // pull fresh history so server URLs come in
                    ref.invalidate(chatHistoryStreamProvider(widget.partnerId));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message send failed')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _askImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
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
            ],
          ),
        );
      },
    );
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
  }
}

/* ---------- Simple message bubble row (keeps your style) ---------- */

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.time,
    required this.isSender,
    this.text,
    this.imageUrl,
    this.localImage, // <— File? for local preview
    this.uploading = false,
  });

  final String? text;
  final String time;
  final bool isSender;
  final String? imageUrl; // server url
  final File? localImage; // local file (optimistic)
  final bool uploading;

  @override
  Widget build(BuildContext context) {
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
                  : Image.network(imageUrl!, fit: BoxFit.cover),
            ),
          ),
          if (uploading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: radius,
              ),
              height: 140.h,
              width: 220.w,
              alignment: Alignment.center,
              child: const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
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
