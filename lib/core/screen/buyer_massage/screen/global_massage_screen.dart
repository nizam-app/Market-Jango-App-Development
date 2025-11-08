import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/data/meassage_data.dart'; // chatListProvider
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/model/massage_list_model.dart';
import 'package:market_jango/core/screen/buyer_massage/widget/custom_textfromfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_chat_screen.dart';

class GlobalMassageScreen extends ConsumerWidget {
  const GlobalMassageScreen({super.key});
  static final routeName = "/buyerMassageScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final chatState = ref.watch(chatListProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages', style: theme.titleLarge),
              SizedBox(height: 16.h),
              CustomTextFromField(
                hintText: "Search",
                prefixIcon: Icons.search_rounded,
                controller: TextEditingController(),
              ),
              SizedBox(height: 16.h),

              chatState.when(
                data: (list) {
                  Logger().i(list);
                  return Expanded(child: ChatListView(chatData: list));
                },
                loading: () =>
                    const Expanded(child: Center(child: Text("Loading..."))),
                error: (e, _) =>
                    Expanded(child: Center(child: Text('Error: $e'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chat list
class ChatListView extends ConsumerWidget {
  const ChatListView({super.key, required this.chatData});
  final List<ChatThread> chatData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: chatData.length,
      separatorBuilder: (_, __) =>
          Divider(height: 22.h, color: AllColor.grey500),
      itemBuilder: (_, i) {
        final chat = chatData[i];
        final bool isUnread = (chat.isRead == 0);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUnread)
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AllColor.blue500,
                  ),
                ),
              SizedBox(width: 6.w),
              CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(chat.partnerImage),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  chat.partnerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              FittedBox(
                child: Row(
                  children: [
                    Text(
                      chat.lastMessageTime,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AllColor.black54,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(Icons.arrow_forward_ios_outlined, size: 15.sp),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Text(
            chat.lastMessage,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(color: isUnread ? AllColor.grey : AllColor.black),
          ),
          onTap: () async {
            SharedPreferences _pefa = await SharedPreferences.getInstance();
            String? myUserId = _pefa.getString('user_id');
            int myUserIdInt = int.parse(myUserId!);
            ref.read(chatListProvider.notifier).markAsRead(chat.chatId);

            context.push(
              ChatScreen.routeName,
              extra: ChatArgs(
                partnerId: chat.partnerId, // তোমার list item থেকে
                partnerName: chat.partnerName,
                partnerImage: chat.partnerImage,
                myUserId: myUserIdInt,
              ),
            );
            ;
          },
        );
      },
    );
  }
}
