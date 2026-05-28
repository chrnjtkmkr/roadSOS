import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'chat_screen.dart';
import 'contacts_screen.dart';
import 'profile_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    ChatScreen(),
    ContactsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabProvider);

    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Stack(
        children: [
          // Background soft image blur fallback
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.network(
                "https://images.unsplash.com/photo-1776042675345-14404ffbcd29?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzb2Z0JTIwZGFyayUyMGZsdWlkJTIwYWJzdHJhY3R8ZW58MXx8fHwxNzc5MjY0NTAyfDA&ixlib=rb-4.1.0&q=80&w=1080",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.slate950,
                ),
              ),
            ),
          ),
          
          // Blur layer
          Positioned.fill(
            child: Container(
              color: AppColors.slate950.withOpacity(0.9),
            ),
          ),
          
          // IndexedStack of screens
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: currentIndex,
                children: _screens,
              ),
            ),
          ),
          
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate900.withOpacity(0.8),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(currentIndex, 0, Icons.home_outlined, Icons.home, 'Home'),
                      _buildNavItem(currentIndex, 1, Icons.map_outlined, Icons.map, 'Map'),
                      _buildNavItem(currentIndex, 2, Icons.message_outlined, Icons.message, 'Chat'),
                      _buildNavItem(currentIndex, 3, Icons.people_outline, Icons.people, 'Contacts'),
                      _buildNavItem(currentIndex, 4, Icons.person_outline, Icons.person, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int currentIndex, int index, IconData outlineIcon, IconData solidIcon, String label) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(currentTabProvider.notifier).state = index;
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? solidIcon : outlineIcon,
            color: isActive ? AppColors.rose400 : AppColors.slate400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.rose400 : AppColors.slate400,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
