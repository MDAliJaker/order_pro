import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const DashboardHeader({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userData = authProvider.userData;
    final profileImage = authProvider.profileImagePath;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Button (Mobile Only - handled by parent layout logic)
          if (MediaQuery.of(context).size.width < 800)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            ),

          if (MediaQuery.of(context).size.width < 800)
            const SizedBox(width: 16),

          // Page Title
          Text(
            userData?['businessName'] ?? 'Dashboard',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Search Bar (Visual only for now)
          if (MediaQuery.of(context).size.width > 600)
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),

          const SizedBox(width: 24),

          // Theme Toggle
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeProvider
                  .toggleTheme(themeProvider.themeMode != ThemeMode.dark);
            },
          ),

          const SizedBox(width: 16),

          // Profile
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userData?['ownerName'] ?? 'Owner',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Owner',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundImage:
                    profileImage != null ? FileImage(File(profileImage)) : null,
                child: profileImage == null
                    ? Text((userData?['ownerName']?.isNotEmpty == true)
                        ? userData!['ownerName'][0]
                        : 'O')
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
