import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/%20business_logic/models/chat_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/buyer_massage/screen/chat_screen.dart';

class BuyerMassageScreen extends StatelessWidget {
  const BuyerMassageScreen({super.key});
  static final routeName= "/buyerMassageScreen";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: 15.w,vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Messages',
                style: theme.titleLarge,
              ),
               SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AllColor.gray300,
                  contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
               SizedBox(height: 16.h),
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

  final List<ChatModel> chatData = const [
    ChatModel(
      avatar: 'https://avatars.githubusercontent.com/u/1?v=4', // Example valid avatar link
      name: 'Company Name',
      message:
      'That’s great, I can help you with that! What type of product are you...',
      time: '9:40 AM',
      unread: false,
    ),
    ChatModel(
      avatar:
      'https://avatars.githubusercontent.com/u/2?v=4', // Example valid avatar link
      name: 'Stephen Yustiono',
      message: "I don't know why people are so anti pineapple pizza. I kind of like it.",
      time: '9:36 AM',
      unread: true,
    ),
    ChatModel(
      avatar:
      'https://avatars.githubusercontent.com/u/3?v=4', // Example valid avatar link
      name: 'Stephen Yustiono',
      message: "I don't know why people are so anti pineapple pizza. I kind of like it.",
      time: '9:36 AM',
      unread: false,
    ),
    ChatModel(
      avatar:
      'https://avatars.githubusercontent.com/u/4?v=4', // Example valid avatar link
      name: 'Stephen Yustiono',
      message: "I don't know why people are so anti pineapple pizza. I kind of like it.",
      time: '9:36 AM',
      unread: true,
    ),
    ChatModel(
      avatar:
      'https://avatars.githubusercontent.com/u/5?v=4', // Example valid avatar link
      name: 'Stephen Yustiono',
      message: "I don't know why people are so anti pineapple pizza. I kind of like it.",
      time: '9:36 AM',
      unread: false,
    ),
    ChatModel(
      avatar:
      'https://avatars.githubusercontent.com/u/6?v=4', // Example valid avatar link
      name: 'Stephen Yustiono',
      message: "I don't know why people are so anti pineapple pizza. I kind of like it.",
      time: '9:36 AM',
      unread: false,
    ),
    ChatModel(
      avatar:
      'https://avatars.githubusercontent.com/u/7?v=4', // Example valid avatar link
      name: 'Stephen Yustiono',
      message: "I don't know why people are so anti pineapple pizza. I kind of like it.",
      time: '9:36 AM',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chatData.length,
      separatorBuilder: (context, index) =>  Divider(height: 22.h,color: AllColor.gray500),
      itemBuilder: (context, index) {
        final chat = chatData[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Row(
            mainAxisSize: MainAxisSize.min, // Add this line
            children: [
              if (chat.unread)
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    color: AllColor.blue500,
                  ),
                ),
              SizedBox(width: 5.w), // Add some space between the dot and avatar
              CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(chat.avatar),
              ),
            ],
          ),
          title: Row(
            children: [
              Text(
                chat.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              FittedBox(
                child: Row(
                  children: [
                    Text(
                      chat.time,textAlign: TextAlign.start,
                      style:  TextStyle(fontSize: 11.sp),

                    ),
                    SizedBox(width: 5.w,),
                    Icon(Icons.arrow_forward_ios_outlined,size: 15.sp,)
                  ],
                ),
              )
            ],
          ),
          subtitle: Text(
            chat.message,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          onTap: () {context.push(ChatScreen.routeName);},
        );
      },
    );
  }
}