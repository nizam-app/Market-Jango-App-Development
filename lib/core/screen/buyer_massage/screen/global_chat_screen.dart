import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Make sure this is imported
import 'package:go_router/go_router.dart';
import 'package:market_jango/%20business_logic/models/chat_model.dart'; // Ensure ChatMessage model is compatible or adjust
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/data/chat_data.dart';
import 'package:market_jango/core/screen/buyer_massage/widget/custom_textfromfield.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart'; // Ensure messages data is compatible or adjust

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static final routeName = "/chatScreen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  // Assuming 'messages' is defined in 'chat_data.dart'
  // Make sure the ChatMessage model and 'messages' list are compatible
  // with the properties used (text, isSender, time, isOrderSummary, etc.)

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.isEmpty) return;
    setState(() {
      messages.insert(
        0,
        ChatMessage( // Ensure ChatMessage constructor matches
          text: text,
          isSender: true,
          time: _getCurrentTime(),
          // Add other necessary fields if your ChatMessage model requires them
        ),
      );
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme
        .of(context)
        .textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AllColor.black,
            size: 17
                .sp, // Use .sp for font sizes or icon sizes that should scale with text
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Row(
          children: [
            CircleAvatar( // Consider making radius responsive if needed: radius: 20.r
              backgroundImage: const NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXZhdGFyfGVufDB8fDB8fHww&w=1000&q=80'),
            ),
            SizedBox(width: 10.w), // Use .w for width
            Text(
              'Curtis Welsh',
              style: theme.titleLarge!.copyWith(
                fontSize: 20.sp, // Use .sp for font sizes
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined, size: 24.sp),
            // Example responsive icon size
            onPressed: () {
              // Handle video call action
            },
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, size: 24.sp),
            // Example responsive icon size
            onPressed: () {
              // Handle call action
            },
          ),
        ],
        backgroundColor: AllColor.white,
        elevation: 1, // Elevation doesn't typically need .r, .w, .h
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              // Use .w and .h
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, int index) => _buildMessageRow(messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          // Height of divider can also be responsive if needed: 1.h
          Container(
            decoration: BoxDecoration(color: Theme
                .of(context)
                .cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(ChatMessage message) {
    CrossAxisAlignment messageAlignment =
    message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    MainAxisAlignment rowAlignment =
    message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      // Use .h for vertical padding
      child: Column(
        crossAxisAlignment: messageAlignment,
        children: [
          Row(
            mainAxisAlignment: rowAlignment,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!message.isSender && !message.isOrderSummary)
                SizedBox(width: 8.w), // Use .w
              Flexible(
                child: message.isOrderSummary
                    ? OrderSummaryBubble(message: message)
                    : MessageBubble(message: message),
              ),
              if (message.isSender && !message.isOrderSummary)
                SizedBox(width: 8.w), // Use .w
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h, // Use .h
              left: message.isSender ? 0 : (message.isOrderSummary ? 16.w : 16
                  .w), // Use .w
              right: !message.isSender ? 0 : (message.isOrderSummary ? 16.w : 16
                  .w), // Use .w
            ),
            child: Text(
              message.time,
              style: TextStyle(
                color: AllColor.grey,
                fontSize: 10.sp, // Use .sp
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme
          .of(context)
          .colorScheme
          .secondary),
      child: Container(
        height: 60.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        // Use .w and .h
        child: Row(
          children: <Widget>[
            Container(
              // Consider making size responsive: padding: EdgeInsets.all(8.r)
              decoration: BoxDecoration(
                color: AllColor.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: AllColor.black54, size: 24.sp),
                // Example
                onPressed: () {
                  // Handle attachment button press
                },
              ),
            ),
            SizedBox(width: 8.w), // Use .w
            Flexible(
              child: CustomTextFromField(hintText: "Type a message...",),
            ),
            SizedBox(width: 8.w), // Use .w
            Container(
              // Consider making size responsive: padding: EdgeInsets.all(8.r)
              decoration: BoxDecoration(
                color: AllColor.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: AllColor.black54,
                    size: 24.sp), // Example
                onPressed: () {
                  // Handle camera button press
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isSender
        ? AllColor.blue.withOpacity(0.2) // Adjusted to a similar color from AllColor
        : AllColor.grey.shade100; // Adjusted to a similar color from AllColor
    final textColor = message.isSender ? AllColor.black87 : AllColor.black87;
    final alignment =
    message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.0.r), // Use .r
      topRight: Radius.circular(16.0.r), // Use .r
      bottomLeft: Radius.circular(message.isSender ? 16.0.r : 0), // Use .r
      bottomRight: Radius.circular(message.isSender ? 0 : 16.0.r), // Use .r
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          // .sw for screen width percentage
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          // .w and .h
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
          ),
          child: Text(
            message.text!, // Ensure message.text is not null
            style: TextStyle(color: textColor, fontSize: 15.sp), // Use .sp
          ),
        ),
      ],
    );
  }
}

class OrderSummaryBubble extends StatelessWidget {
  final ChatMessage message;

  const OrderSummaryBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 0.75.sw),
      // .sw
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      // .w and .h
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(16.0.r),
        // .r
        border: Border.all(color: AllColor.blue, width: 1.5.w),
        // .w for border width
        boxShadow: [
          BoxShadow(
            color: AllColor.grey.withOpacity(0.2),
            spreadRadius: 1.r, // .r
            blurRadius: 3.r, // .r
            offset: Offset(0, 2.h), // .h for y-offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (message.imageUrls != null && message.imageUrls!.isNotEmpty)
                Container(
                  width: 50.w, // .w
                  height: 50.h, // .h
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r), // .r
                    image: DecorationImage(
                      image: NetworkImage(message.imageUrls![0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: EdgeInsets.only(right: 8.w), // .w
                ),
              if (message.imageUrls != null && message.imageUrls!.length > 1)
                Column(
                  children: message.imageUrls!
                      .sublist(1,
                      message.imageUrls!.length > 3 ? 3 : message.imageUrls!
                          .length)
                      .map((url) {
                    return Container(
                      width: 23.w, // .w
                      height: 23.h, // .h
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r), // .r
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(bottom: 4.h), // .h
                    );
                  }).toList(),
                ),
              SizedBox(width: 12.w), // .w
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${message.orderNumber!}', // Ensure not null
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp), // .sp
                    ),
                    Text(
                      message.deliveryType!, // Ensure not null
                      style: TextStyle(
                          color: AllColor.grey, fontSize: 12.sp), // .sp
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h), // .h
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                 context.push(BuyerPaymentScreen.routeName);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 8.h), // .w and .h
                  backgroundColor: AllColor.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r), // .r
                  ),
                ),
                child: Text(
                  'Pay Now',
                  style: TextStyle(color: AllColor.white, fontSize: 14.sp), // .sp
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                // .w and .h
                decoration: BoxDecoration(
                  color: AllColor.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r), // .r
                ),
                child: Text(
                  '${message.itemCount} Items', // Ensure not null
                  style: TextStyle(fontSize: 12.sp, color: AllColor.black54), // .sp
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}