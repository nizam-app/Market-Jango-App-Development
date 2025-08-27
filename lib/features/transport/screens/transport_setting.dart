import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransportSetting extends StatelessWidget {
  const TransportSetting({super.key});

  static const String routeName = '/transport_setting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              SettingTitle(),
              SizedBox(height: 24),
              ProfileSection(),
              SizedBox(height: 30),
              InfoRow(icon: Icons.phone, text: "(319) 555-0115"),
              SizedBox(height: 16),
              InfoRow(icon: Icons.email_outlined, text: "mirable@gmail.com"),
              SizedBox(height: 24),
              SettingItem(
                icon: Icons.language,
                text: "Language",
                onTap:(){
                  context.push("/language");
                },
              ),


              Divider(height: 32),
              SettingItem(
                icon: Icons.logout,
                text: "Log Out",
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: null, // Replace with callback if needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingTitle extends StatelessWidget {
  const SettingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "My Settings",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(
                "https://randomuser.me/api/portraits/women/68.jpg",
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.camera_alt, size: 16),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mirable Lily",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    "mirable123",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Private",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            context.push("/editProfile");
          },
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? Colors.grey),
      title: Text(text, style: TextStyle(color: textColor ?? Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
      onTap: onTap,
    );
  }
}
