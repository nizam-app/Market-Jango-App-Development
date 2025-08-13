import 'package:flutter/material.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
static final routeName = "/chatScreen";
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hi! I want to buy a red cotton kurti. Do you have Size M?',
      isSender: true,
      time: '7:15 PM',
    ),
    ChatMessage(
      text:
      'Hello! Yes, a red cotton kurti in Size M is available, I can create an order for you now if you\'d like.',
      isSender: false,
      time: '7:15 PM',
    ),
    ChatMessage(
      text: 'Okay. What\'s the price? When will it be delivered?',
      isSender: true,
      time: '7:15 PM',
    ),
    ChatMessage(
      text:
      'The price is 799 Taka, delivery within 3 days. If you confirm, I\'ll place the order.',
      isSender: false,
      time: '7:15 PM',
    ),
    ChatMessage(
      text: 'Okay, go ahead. Do you offer Cash on Delivery?',
      isSender: true,
      time: '7:16 PM',
    ),
    // Placeholder for the order summary message
    ChatMessage(
      isOrderSummary: true,
      orderNumber: '#92287157',
      deliveryType: 'Standard Delivery',
      itemCount: 3,
      isSender: false,
      // Or true, depending on who sends this message
      time: '7:16 PM',
      imageUrls: [
        'https://via.placeholder.com/150/92C952',
        // Replace with your actual image URLs
        'https://via.placeholder.com/150/771796',
        'https://via.placeholder.com/150/24F355',
        'https://via.placeholder.com/150/8985DC',
      ],
    ),
    ChatMessage(
      text:
      'Lorem ipsum dolor sit amet consectetur. Diam convallis non morbi feugiat',
      isSender: false,
      time: '7:16 PM',
    ),
  ];

  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () {
            // Handle back button press
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Replace with your avatar URL
            ),
            const SizedBox(width: 10),
            const Text(
              'Curtis Welsh',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black54),
            onPressed: () {
              // Handle video call action
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.black54),
            onPressed: () {
              // Handle call action
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessageRow(_messages[index]),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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

class ChatMessage {
  final String? text;
  final bool isSender;
  final String time;
  final bool isOrderSummary;
  final String? orderNumber;
  final String? deliveryType;
  final int? itemCount;
  final List<String>? imageUrls;


  ChatMessage({
    this.text,
    required this.isSender,
    required this.time,
    this.isOrderSummary = false,
    this.orderNumber,
    this.deliveryType,
    this.itemCount,
    this.imageUrls,
  }) : assert(isOrderSummary ? (orderNumber != null && deliveryType != null &&
      itemCount != null && imageUrls != null) : text != null);
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