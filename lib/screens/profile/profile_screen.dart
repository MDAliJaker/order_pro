import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'add_profile_image_screen.dart';
import '../settings/currency_selection_screen.dart';
import 'privacy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final profileImage = authProvider.profileImagePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Image
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profileImage != null
                      ? FileImage(File(profileImage))
                      : null,
                  child: profileImage == null
                      ? Text(
                          userData?['ownerName']?[0] ?? 'O',
                          style: const TextStyle(fontSize: 40),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon:
                          const Icon(Icons.photo_library, color: Colors.white),
                      tooltip: 'Choose Profile Image',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProfileImageScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Profile Info Cards
          _InfoCard(
            icon: Icons.person,
            label: 'Owner Name',
            value: userData?['ownerName'] ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.business,
            label: 'Business Name',
            value: userData?['businessName'] ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.email,
            label: 'Email',
            value: userData?['email'] ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.phone,
            label: 'Phone',
            value: userData?['phone'] ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.numbers,
            label: 'BIN / TIN',
            value: userData?['binTin'] ?? 'N/A',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.location_on,
            label: 'Address',
            value: [
              userData?['street'],
              userData?['subCity'],
              userData?['city'],
              userData?['state']
            ].where((e) => e != null && e.isNotEmpty).join(', ').isEmpty
                ? 'N/A'
                : [
                    userData?['street'],
                    userData?['subCity'],
                    userData?['city'],
                    userData?['state']
                  ].where((e) => e != null && e.isNotEmpty).join(', '),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.attach_money,
            label: 'Currency',
            value:
                '${authProvider.currency.name} (${authProvider.currency.symbol})',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CurrencySelectionScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.security,
            label: 'Privacy',
            value: 'Security Questions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          ),
          const SizedBox(height: 32),

          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
