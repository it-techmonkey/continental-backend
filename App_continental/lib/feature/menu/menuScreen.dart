// lib/menu_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/language_service.dart';
import 'profile_provider.dart';

// Helper class to hold data for our menu items
class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.title, required this.onTap});
}

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(languageProvider);
    final translate = (String key) => LanguageService.translate(key, languageCode);
    
    final menuItems = [
      MenuItem(icon: CupertinoIcons.question_circle, title: translate('Help'), onTap: () {}),
      MenuItem(
        icon: Icons.translate,
        title: translate('Language Settings'),
        onTap: () {
          _showLanguageDialog(context, ref);
        },
      ),
      MenuItem(
        icon: Icons.payment,
        title: translate('Payments'),
        onTap: () {
          context.goNamed('payments');
        },
      ),
      MenuItem(
        icon: Icons.logout,
        title: translate('Log Out'),
        onTap: () async {
          // Logout and navigate to login screen
          await ref.read(authStateProvider.notifier).logout();
          context.goNamed('login');
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 30),
            // Use ListView.separated to automatically add dividers
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _MenuListItem(
                  icon: item.icon,
                  title: item.title,
                  onTap: item.onTap,
                );
              },
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[900],
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for the top profile section
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final profileAsync = ref.watch(profileProvider);
    final languageCode = ref.watch(languageProvider);
    final translate = (String key) => LanguageService.translate(key, languageCode);
    final role = auth.user?.role ?? 'User';
    
    // Use profile data if available, otherwise fall back to auth
    final profileData = profileAsync.value;
    final name = profileData?.name ?? auth.user?.name ?? 'User';
    final imageUrl = profileData?.imageUrl ?? 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80';
    
    return InkWell(
      onTap: ()=>{
          context.goNamed('profile')
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role,
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    translate('Edit Profile'),
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for each item in the menu list
class _MenuListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuListItem(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.inter(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
    );
  }
}

void _showLanguageDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Consumer(
        builder: (context, ref, _) {
          final languageCode = ref.watch(languageProvider);
          final translate = (String key) => LanguageService.translate(key, languageCode);
          
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              translate('Language Settings'),
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('English', style: TextStyle(color: Colors.white)),
                  value: 'en',
                  groupValue: languageCode,
                  activeColor: Colors.yellow[700],
                  onChanged: (value) async {
                    if (value != null && value != languageCode) {
                      await ref.read(languageProvider.notifier).setLanguage(value);
                      // Wait a bit longer to see the change
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Français', style: TextStyle(color: Colors.white)),
                  value: 'fr',
                  groupValue: languageCode,
                  activeColor: Colors.yellow[700],
                  onChanged: (value) async {
                    if (value != null && value != languageCode) {
                      await ref.read(languageProvider.notifier).setLanguage(value);
                      // Wait a bit longer to see the change
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}