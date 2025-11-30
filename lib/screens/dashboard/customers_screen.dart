import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/search_delegates.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final customers = orderProvider.customers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomerSearchDelegate(customers),
              );
            },
          ),
        ],
      ),
      body: customers.isEmpty
          ? const Center(
              child: Text('No customers found.'),
            )
          : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                final lastOrder = orderProvider.getLastOrder(customer.id);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(customer.name[0].toUpperCase()),
                    ),
                    title: Text(customer.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.phone),
                        if (lastOrder != null)
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => Text(
                              'Last Order: ${DateFormat('MMM dd').format(lastOrder.createdAt)} - ${auth.currency.symbol}${lastOrder.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          const Text(
                            'No orders yet',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerDetailScreen(customer: customer),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
