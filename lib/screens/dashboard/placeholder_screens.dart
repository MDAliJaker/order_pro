import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/search_delegates.dart';
import '../../widgets/invoice_preview_dialog.dart';

class OrdersQueueScreen extends StatelessWidget {
  const OrdersQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final pendingOrders = orderProvider.pendingOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders in Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(pendingOrders, orderProvider),
              );
            },
          ),
        ],
      ),
      body: pendingOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pending orders',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingOrders.length,
              itemBuilder: (context, index) {
                final order = pendingOrders[index];
                return _OrderCard(
                  order: order,
                  onComplete: () async {
                    orderProvider.updateOrderStatus(order.id, 'completed');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Order completed! Preparing invoice...')),
                    );

                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);

                    // Show invoice preview dialog
                    showDialog(
                      context: context,
                      builder: (context) => InvoicePreviewDialog(
                        order: order,
                        businessInfo: authProvider.userData ?? {},
                        currencyName: authProvider.currency.name,
                      ),
                    );
                  },
                  onCancel: () {
                    orderProvider.updateOrderStatus(order.id, 'cancelled');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order cancelled')),
                    );
                  },
                );
              },
            ),
    );
  }
}

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final completedOrders = orderProvider.completedOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(
                  completedOrders,
                  orderProvider,
                  isHistory: true,
                ),
              );
            },
          ),
        ],
      ),
      body: completedOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No completed orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                final order = completedOrders[index];
                return _OrderCard(
                  order: order,
                  isHistory: true,
                  onComplete: () {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);

                    // Show invoice preview dialog
                    showDialog(
                      context: context,
                      builder: (context) => InvoicePreviewDialog(
                        order: order,
                        businessInfo: authProvider.userData ?? {},
                        currencyName: authProvider.currency.name,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final completedOrders = orderProvider.completedOrders;
    final todaysSales = orderProvider.todaysSales;
    final currencySymbol = authProvider.currency.symbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Today's Sales",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$currencySymbol${todaysSales.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${completedOrders.length} orders completed',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: completedOrders.isEmpty
                ? Center(
                    child: Text(
                      'No sales yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: completedOrders.length,
                    itemBuilder: (context, index) {
                      final order = completedOrders[index];
                      return _OrderCard(
                        order: order,
                        isHistory: true,
                        onComplete: () {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);

                          // Show invoice preview dialog
                          showDialog(
                            context: context,
                            builder: (context) => InvoicePreviewDialog(
                              order: order,
                              businessInfo: authProvider.userData ?? {},
                              currencyName: authProvider.currency.name,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final bool isHistory;

  const _OrderCard({
    required this.order,
    this.onComplete,
    this.onCancel,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currencySymbol = authProvider.currency.symbol;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(order.customer.name[0].toUpperCase()),
        ),
        title: Text(order.customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${order.customer.id}'),
            Text('Phone: ${order.customer.phone}'),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currencySymbol${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${order.items.length} items',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${item.itemName} x${item.quantity}'),
                          ),
                          Text(
                            '$currencySymbol${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$currencySymbol${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                if (!isHistory) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(Icons.check),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isHistory && onComplete != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.print),
                    label: const Text('Print Invoice'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
