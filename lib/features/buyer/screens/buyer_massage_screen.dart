import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class BuyerMassageScreen extends StatelessWidget {
  const BuyerMassageScreen({super.key});
  static final routeName= "/buyerMassageScreen";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color(0xFFD6CAC5),
      body: SafeArea(
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: 15.w,vertical: 15.h),
          color: AllColor.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Messages',
                style: theme.titleLarge,
              ),
               SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF1F1F1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Expanded(child: ChatListView()),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  final List<Map<String, dynamic>> chatData = const [
    {
      'avatar': 'https://via.placeholder.com/40?text=LOGO',
      'name': 'Company Name',
      'message':
      'That’s great, I can help you with that! What type of product are you...',
      'time': '9:40 AM',
      'unread': false,
    },
    {
      'avatar':
      'https://raw.githubusercontent.com/flutter/plugins/master/packages/image_picker/image_picker/example/assets/person1.png',
      'name': 'Stephen Yustiono',
      'message': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'time': '9:36 AM',
      'unread': true,
    },
    {
      'avatar':
      'https://raw.githubusercontent.com/flutter/plugins/master/packages/image_picker/image_picker/example/assets/person2.png',
      'name': 'Stephen Yustiono',
      'message': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'time': '9:36 AM',
      'unread': false,
    },
    {
      'avatar':
      'https://raw.githubusercontent.com/flutter/plugins/master/packages/image_picker/image_picker/example/assets/person3.png',
      'name': 'Stephen Yustiono',
      'message': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'time': '9:36 AM',
      'unread': true,
    },
    {
      'avatar':
      'https://raw.githubusercontent.com/flutter/plugins/master/packages/image_picker/image_picker/example/assets/person4.png',
      'name': 'Stephen Yustiono',
      'message': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'time': '9:36 AM',
      'unread': false,
    },
    {
      'avatar':
      'https://raw.githubusercontent.com/flutter/plugins/master/packages/image_picker/image_picker/example/assets/person5.png',
      'name': 'Stephen Yustiono',
      'message': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'time': '9:36 AM',
      'unread': false,
    },
    {
      'avatar':
      'https://raw.githubusercontent.com/flutter/plugins/master/packages/image_picker/image_picker/example/assets/person1.png',
      'name': 'Stephen Yustiono',
      'message': "I don't know why people are so anti pineapple pizza. I kind of like it.",
      'time': '9:36 AM',
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chatData.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final chat = chatData[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(chat['avatar']),
              ),
              if (chat['unread'])
                Positioned(
                  top: -2,
                  left: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            chat['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            chat['message'],
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            chat['time'],
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {},
        );
      },
    );
  }
}