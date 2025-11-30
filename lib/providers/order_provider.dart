import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class Customer {
  final String id;
  String name;
  String phone;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
    );
  }
}

class OrderItem {
  final String inventoryItemId;
  final String itemName;
  final double price;
  int quantity;

  OrderItem({
    required this.inventoryItemId,
    required this.itemName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap(String orderId) {
    return {
      'orderId': orderId,
      'inventoryItemId': inventoryItemId,
      'itemName': itemName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      inventoryItemId: map['inventoryItemId'],
      itemName: map['itemName'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}

class Order {
  final String id;
  final Customer customer;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String status; // 'pending', 'completed', 'cancelled'

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.createdAt,
    required this.status,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customer.id,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'totalAmount': total,
    };
  }
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Customer> _customers = [];

  List<Order> get orders => _orders;
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();
  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'completed').toList();
  List<Customer> get customers => _customers;

  OrderProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper.instance.database;

    // Load Customers
    final customerMaps = await db.query('customers');
    _customers = List.generate(
        customerMaps.length, (i) => Customer.fromMap(customerMaps[i]));

    // Load Orders
    final orderMaps = await db.query('orders', orderBy: 'createdAt DESC');
    _orders = [];

    for (var orderMap in orderMaps) {
      final customer =
          _customers.firstWhere((c) => c.id == orderMap['customerId']);

      final orderItemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderMap['id']],
      );

      final items = List.generate(
          orderItemMaps.length, (i) => OrderItem.fromMap(orderItemMaps[i]));

      _orders.add(Order(
        id: orderMap['id'] as String,
        customer: customer,
        items: items,
        createdAt: DateTime.parse(orderMap['createdAt'] as String),
        status: orderMap['status'] as String,
      ));
    }
    notifyListeners();
  }

  // Get or create customer
  Future<Customer> getOrCreateCustomer(String name, String phone) async {
    final db = await DatabaseHelper.instance.database;

    // Check if customer exists by phone
    final existing = _customers.where((c) => c.phone == phone).firstOrNull;
    if (existing != null) {
      // Update name if changed
      if (existing.name != name) {
        existing.name = name;
        await db.update(
          'customers',
          {'name': name},
          where: 'id = ?',
          whereArgs: [existing.id],
        );
        notifyListeners();
      }
      return existing;
    }

    // Create new customer
    final customer = Customer(
      id: 'CUST${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
    );

    await db.insert('customers', customer.toMap());
    _customers.add(customer);
    notifyListeners();
    return customer;
  }

  Future<void> addOrder(Order order) async {
    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {
      await txn.insert('orders', order.toMap());
      for (var item in order.items) {
        await txn.insert('order_items', item.toMap(order.id));
      }
    });

    _orders.insert(0, order); // Add to beginning for newest first
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final order = _orders[index];
      _orders[index] = Order(
        id: order.id,
        customer: order.customer,
        items: order.items,
        createdAt: order.createdAt,
        status: status,
      );
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn
          .delete('order_items', where: 'orderId = ?', whereArgs: [orderId]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    });

    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  // Get orders for a specific customer
  List<Order> getOrdersByCustomer(String customerId) {
    return _orders.where((o) => o.customer.id == customerId).toList();
  }

  // Get last order for a specific customer
  Order? getLastOrder(String customerId) {
    final customerOrders = getOrdersByCustomer(customerId);
    if (customerOrders.isEmpty) return null;
    // Orders are already sorted by createdAt DESC in _loadData
    return customerOrders.first;
  }

  // Get today's sales
  double get todaysSales {
    final today = DateTime.now();
    return _orders
        .where((o) =>
            o.status == 'completed' &&
            o.createdAt.year == today.year &&
            o.createdAt.month == today.month &&
            o.createdAt.day == today.day)
        .fold(0.0, (sum, order) => sum + order.total);
  }
}
