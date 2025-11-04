import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/data/meassage_data.dart';
import 'package:market_jango/core/screen/buyer_massage/model/massage_list_model.dart';
import 'package:market_jango/core/screen/buyer_massage/widget/custom_textfromfield.dart';

import 'global_chat_screen.dart';
class GlobalMassageScreen extends ConsumerWidget{
  const GlobalMassageScreen({super.key});

  // Route name for navigation.
  static final routeName = "/buyerMassageScreen";

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          // Apply padding to the container.
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title text for the screen.
              Text(
                'Messages',
                style : theme.titleLarge,
              ),
              SizedBox(height: 16.h), // Spacing.
              // Custom text field for searching messages.
              CustomTextFromField(
                hintText: "Search",
                prefixIcon: Icons.search_rounded,
              ),
              SizedBox(height: 16.h), // Spacing.
              // Expanded widget to fill available space with the chat list.
              chatState.when(
                data: (data) {
                  Logger().i(data);
                 
                  return Expanded(child: ChatListView(chatData:data));
                },
                loading: () => const Center(child: Text("Loading...")),
                error: (error, stackTrace) => Center(child: Text(error.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for displaying a list of chats.
class ChatListView extends StatelessWidget {
  const ChatListView({super.key, required this.chatData});
  final List<ChatThread> chatData;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chatData.length,
      separatorBuilder: (context, index) =>  Divider(height: 22.h,color: AllColor.grey500),
      itemBuilder: (context, index) {
        // Get the chat data for the current item.
        final chat = chatData[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display a blue dot if the message is unread.
              if (chat.isRead)
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    color: AllColor.blue500,
                  ),
                ),
              SizedBox(width: 5.w), // Spacing between dot and avatar.
              CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(chat.partnerImage),
              ),
            ],
          ),
          title: Row(
            children: [
              Text(
                chat.partnerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(), // Pushes the following widgets to the right.
              FittedBox(
                child: Row(
                  children: [
                    // Display the time of the message.
                    Text(
                      chat.lastMessageTime,textAlign: TextAlign.start,
                      style:  TextStyle(fontSize: 11.sp),
                    ),
                    SizedBox(width: 5.w,), // Spacing.
                    // Forward arrow icon.
                    Icon(Icons.arrow_forward_ios_outlined,size: 15.sp,)
                  ],
                ),
              )
            ],
          ),
          // Display the message content with ellipsis for overflow.
          subtitle: Text(
            chat.lastMessage,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          // Navigate to the chat screen when tapped.
          onTap: () {context.push(ChatScreen.routeName);},
        );
      },
    );
  }
}