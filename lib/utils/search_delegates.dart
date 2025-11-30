import 'dart:io';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../providers/order_provider.dart';
import '../screens/inventory/add_edit_item_screen.dart';
import '../screens/dashboard/customer_detail_screen.dart';

// --- Inventory Search Delegate ---
class InventorySearchDelegate extends SearchDelegate {
  final List<InventoryItem> items;
  final InventoryProvider provider;

  InventorySearchDelegate(this.items, this.provider);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final results = items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: item.imagePath != null
              ? CircleAvatar(backgroundImage: FileImage(File(item.imagePath!)))
              : CircleAvatar(child: Text(item.name[0])),
          title: Text(item.name),
          subtitle: Text('Qty: ${item.quantity} | \$${item.price}'),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditItemScreen(item: item),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Customer Search Delegate ---
class CustomerSearchDelegate extends SearchDelegate {
  final List<Customer> customers;

  CustomerSearchDelegate(this.customers);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final results = customers.where((customer) {
      final nameMatch =
          customer.name.toLowerCase().contains(query.toLowerCase());
      final phoneMatch = customer.phone.contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No customers found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final customer = results[index];
        return ListTile(
          leading: CircleAvatar(child: Text(customer.name[0].toUpperCase())),
          title: Text(customer.name),
          subtitle: Text(customer.phone),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomerDetailScreen(customer: customer),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Order Search Delegate ---
class OrderSearchDelegate extends SearchDelegate {
  final List<Order> orders;
  final OrderProvider provider;
  final bool isHistory;

  OrderSearchDelegate(this.orders, this.provider, {this.isHistory = false});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final results = orders.where((order) {
      final nameMatch =
          order.customer.name.toLowerCase().contains(query.toLowerCase());
      final phoneMatch = order.customer.phone.contains(query);
      final idMatch = order.id.toLowerCase().contains(query.toLowerCase());
      return nameMatch || phoneMatch || idMatch;
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No orders found'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final order = results[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(order.customer.name[0].toUpperCase()),
          ),
          title: Text(order.customer.name),
          subtitle: Text(
            '${DateFormat('MMM dd, hh:mm a').format(order.createdAt)} - \$${order.total.toStringAsFixed(2)}',
          ),
          trailing: Text(order.status.toUpperCase()),
          onTap: () {
            // In a real app, we might navigate to an order detail screen.
            // For now, we just close search.
            close(context, null);
          },
        );
      },
    );
  }
}
