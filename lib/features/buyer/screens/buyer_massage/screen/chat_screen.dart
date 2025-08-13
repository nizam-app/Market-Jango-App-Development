import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/%20business_logic/models/chat_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/data/chat_data.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
static final routeName = "/chatScreen";
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.isEmpty) return;
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          text: text,
          isSender: true,
          time: _getCurrentTime(),
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
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color:AllColor.black,size: 17.sp,),
          onPressed: () {
            // Handle back button press
            context.pop();
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YXZhdGFyfGVufDB8fDB8fHww&w=1000&q=80'), // Replace with your avatar URL
            ),
             SizedBox(width: 10.w),
             Text(
              'Curtis Welsh',
              style:theme.titleLarge!.copyWith(
                fontSize: 20.sp,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // Handle video call action
              // handleVideoCall();
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              // Handle call action
              //  handleAduioCall();
            },
          ),
        ],
        backgroundColor: AllColor.white,
        elevation: 1,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, int index) => _buildMessageRow(messages[index]),
            ),
          ),
          const Divider(height: 1.0),
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
    CrossAxisAlignment messageAlignment = message.isSender ? CrossAxisAlignment
        .end : CrossAxisAlignment.start;
    MainAxisAlignment rowAlignment = message.isSender
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 4.0.h),
      child: Column(
        crossAxisAlignment: messageAlignment,
        children: [
          Row(
            mainAxisAlignment: rowAlignment,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!message.isSender && !message.isOrderSummary)
                const SizedBox(width: 8), // For spacing before receiver bubble
              Flexible(
                child: message.isOrderSummary
                    ? OrderSummaryBubble(message: message)
                    : MessageBubble(message: message),
              ),
              if (message.isSender && !message.isOrderSummary)
                const SizedBox(width: 8), // For spacing after sender bubble
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.0,
              left: message.isSender ? 0 : (message.isOrderSummary ? 16 : 16),
              // Adjust left padding for timestamp
              right: !message.isSender ? 0 : (message.isOrderSummary
                  ? 16
                  : 16), // Adjust right padding for timestamp
            ),
            child: Text(
              message.time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10.0,
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
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.black54),
                onPressed: () {
                  // Handle attachment button press
                },
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Type something',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                    Icons.camera_alt_outlined, color: Colors.black54),
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
        ? const Color(0xFFE1F5FE) // Light blue for sender
        : const Color(0xFFF5F5F5); // Light grey for receiver
    final textColor = message.isSender ? Colors.black87 : Colors.black87;
    final alignment =
    message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16.0),
      topRight: const Radius.circular(16.0),
      bottomLeft: Radius.circular(message.isSender ? 16.0 : 0),
      bottomRight: Radius.circular(message.isSender ? 0 : 16.0),
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
          ),
          child: Text(
            message.text!,
            style: TextStyle(color: textColor, fontSize: 15),
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
      constraints:
      BoxConstraints(maxWidth: MediaQuery
          .of(context)
          .size
          .width * 0.75),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.blue[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Display first image larger
              if (message.imageUrls != null && message.imageUrls!.isNotEmpty)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(message.imageUrls![0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: const EdgeInsets.only(right: 8),
                ),
              // Display other images smaller in a column
              if (message.imageUrls != null && message.imageUrls!.length > 1)
                Column(
                  children: message.imageUrls!.sublist(1,
                      message.imageUrls!.length > 3 ? 3 : message.imageUrls!
                          .length).map((url) { // Limit to 2 small images
                    return Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: const EdgeInsets.only(
                          bottom: 4), // Spacing between small images
                    );
                  }).toList(),
                ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${message.orderNumber!}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      message.deliveryType!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Handle Pay Now action
                },
                style: TextButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${message.itemCount} Items',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}