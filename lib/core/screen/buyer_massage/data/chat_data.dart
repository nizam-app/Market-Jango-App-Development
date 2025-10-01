import 'package:market_jango/%20business_logic/models/chat_model.dart';

final List<ChatMessage> messages = [
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
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Example: Shoe
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1999&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Example: Watch
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Example: Headphones
      'https://images.unsplash.com/photo-1572635196237-14b3f281503f?q=80&w=1780&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Example: Sunglasses
    ],
  ),
  ChatMessage(
    text:
    'Lorem ipsum dolor sit amet consectetur. Diam convallis non morbi feugiat',
    isSender: false,
    time: '7:16 PM',
  ),
];