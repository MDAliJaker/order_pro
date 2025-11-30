import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';

class TakeOrderScreen extends StatefulWidget {
  const TakeOrderScreen({super.key});

  @override
  State<TakeOrderScreen> createState() => _TakeOrderScreenState();
}

class _TakeOrderScreenState extends State<TakeOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final List<OrderItem> _orderItems = [];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _addItemToOrder(InventoryItem inventoryItem) {
    setState(() {
      // Check if item already in order
      final existingIndex = _orderItems.indexWhere(
        (item) => item.inventoryItemId == inventoryItem.id,
      );

      if (existingIndex >= 0) {
        // Increase quantity
        _orderItems[existingIndex].quantity++;
      } else {
        // Add new item
        _orderItems.add(OrderItem(
          inventoryItemId: inventoryItem.id,
          itemName: inventoryItem.name,
          price: inventoryItem.price,
          quantity: 1,
        ));
      }
    });
  }

  void _removeItemFromOrder(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = _orderItems[index].quantity + change;
      if (newQuantity > 0) {
        _orderItems[index].quantity = newQuantity;
      } else {
        _orderItems.removeAt(index);
      }
    });
  }

  double get _orderTotal {
    return _orderItems.fold(0, (sum, item) => sum + item.total);
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate() && _orderItems.isNotEmpty) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Get or create customer
      final customer = await orderProvider.getOrCreateCustomer(
        _customerNameController.text,
        _customerPhoneController.text,
      );

      // Create order
      final order = Order(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        customer: customer,
        items: List.from(_orderItems),
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await orderProvider.addOrder(order);

      // Update inventory quantities
      final inventoryProvider =
          Provider.of<InventoryProvider>(context, listen: false);
      for (var item in _orderItems) {
        await inventoryProvider.decreaseQuantity(
            item.inventoryItemId, item.quantity);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed for ${customer.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to the order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Order'),
        actions: [
          if (_orderItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _placeOrder,
            ),
        ],
      ),
      body: Column(
        children: [
          // Customer Information Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (Unique ID)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Order Items Section
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: \$${_orderTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_orderItems.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No items added yet.\nSelect items from inventory below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _orderItems.length,
                      itemBuilder: (context, index) {
                        final item = _orderItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(item.itemName),
                            subtitle:
                                Text('\$${item.price.toStringAsFixed(2)} each'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _updateQuantity(index, -1),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateQuantity(index, 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeItemFromOrder(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Available Inventory
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Available Inventory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: inventoryProvider.items.isEmpty
                      ? const Center(
                          child: Text(
                            'No inventory items available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: inventoryProvider.items.length,
                          itemBuilder: (context, index) {
                            final item = inventoryProvider.items[index];
                            return Card(
                              child: InkWell(
                                onTap: () => _addItemToOrder(item),
                                child: Container(
                                  width: 140,
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stock: ${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _orderItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _placeOrder,
              icon: const Icon(Icons.check),
              label: Text('Place Order (\$${_orderTotal.toStringAsFixed(2)})'),
            )
          : null,
    );
  }
}
