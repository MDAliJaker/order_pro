import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/summary_card.dart';
import 'take_order_screen.dart';
import 'placeholder_screens.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/sales_chart.dart';
import '../../widgets/inventory_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currencySymbol = authProvider.currency.symbol;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        int crossAxisCount = constraints.maxWidth > 1400
            ? 4
            : constraints.maxWidth > 1100
                ? 3
                : constraints.maxWidth > 800
                    ? 2
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;

        return Scaffold(
          key: _scaffoldKey,
          // Only show drawer on mobile
          drawer: !isDesktop ? const Drawer(child: SideBar()) : null,
          body: Row(
            children: [
              // Permanent Sidebar on Desktop
              if (isDesktop) const SideBar(),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Header
                    DashboardHeader(
                      onMenuPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),

                    // Dashboard Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary Cards Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 1.4,
                              children: [
                                SummaryCard(
                                  title: "Today's Sales",
                                  value:
                                      "$currencySymbol${orderProvider.todaysSales.toStringAsFixed(2)}",
                                  icon: Icons.attach_money,
                                  color: Colors.green,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SalesScreen()),
                                    );
                                  },
                                ),
                                SummaryCard(
                                  title: "Orders in Queue",
                                  value:
                                      "${orderProvider.pendingOrders.length}",
                                  icon: Icons.queue,
                                  color: Colors.orange,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const OrdersQueueScreen()),
                                    );
                                  },
                                ),
                                SummaryCard(
                                  title: "Orders Done",
                                  value:
                                      "${orderProvider.completedOrders.length}",
                                  icon: Icons.check_circle,
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const OrdersHistoryScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Charts Section
                            if (constraints.maxWidth > 800)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Expanded(child: SalesChart()),
                                  SizedBox(width: 24),
                                  Expanded(child: InventoryChart()),
                                ],
                              )
                            else
                              Column(
                                children: const [
                                  SalesChart(),
                                  SizedBox(height: 24),
                                  InventoryChart(),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TakeOrderScreen()),
              );
            },
            label: const Text(
              'Take Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.add_shopping_cart),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
