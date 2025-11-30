import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/dashboard/customers_screen.dart';
import '../screens/dashboard/placeholder_screens.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/manage_staff_screen.dart';
import '../screens/profile/staff_salary_screen.dart';
import '../screens/settings/settings_screen.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo / Brand
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 40,
                      color: isDark ? Colors.white : theme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Order Pro',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Role Badge
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final isOwner = authProvider.isOwner;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOwner
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOwner ? Colors.amber : Colors.blue,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOwner ? Icons.star : Icons.person,
                            size: 14,
                            color: isOwner ? Colors.amber : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            authProvider.userRole,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isOwner ? Colors.amber : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: true,
                  onTap: () {}, // Already on Dashboard
                ),
                _SidebarItem(
                  icon: Icons.inventory,
                  label: 'Inventory',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InventoryScreen()),
                    );
                  },
                ),
                _SidebarItem(
                  icon: Icons.people,
                  label: 'Customers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomersScreen()),
                    );
                  },
                ),
                _SidebarItem(
                  icon: Icons.queue,
                  label: 'Orders in Queue',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OrdersQueueScreen()),
                    );
                  },
                ),
                _SidebarItem(
                  icon: Icons.shopping_cart,
                  label: 'Order History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OrdersHistoryScreen()),
                    );
                  },
                ),
                _SidebarItem(
                  icon: Icons.analytics,
                  label: 'Reports',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SalesScreen()),
                    );
                  },
                ),
                const Divider(height: 32),
                // Manage Staff (Owner only)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (!authProvider.isOwner) return const SizedBox.shrink();
                    return _SidebarItem(
                      icon: Icons.group,
                      label: 'Manage Staff',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ManageStaffScreen()),
                        );
                      },
                    );
                  },
                ),
                // Salary Management (Owner only)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (!authProvider.isOwner) return const SizedBox.shrink();
                    return _SidebarItem(
                      icon: Icons.attach_money,
                      label: 'Salary Management',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StaffSalaryScreen()),
                        );
                      },
                    );
                  },
                ),
                _SidebarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                _SidebarItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _SidebarItem(
              icon: Icons.logout,
              label: 'Logout',
              isDestructive: true,
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDestructive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDestructive
        ? Colors.red
        : isActive
            ? (isDark ? Colors.greenAccent : theme.primaryColor)
            : theme.textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: isActive
              ? BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: theme.primaryColor,
                      width: 4,
                    ),
                  ),
                  color: theme.primaryColor.withOpacity(0.1),
                )
              : null,
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
