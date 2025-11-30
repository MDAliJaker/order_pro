import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class InventoryItem {
  final String id;
  String name;
  double price;
  int quantity;
  String? imagePath;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      imagePath: map['imagePath'],
    );
  }
}

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];

  List<InventoryItem> get items => _items;

  InventoryProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('inventory_items');
    _items = List.generate(maps.length, (i) => InventoryItem.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('inventory_items', item.toMap());
    _items.add(item);
    notifyListeners();
  }

  Future<void> updateItem(String id, InventoryItem newItem) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'inventory_items',
      newItem.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = newItem;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'inventory_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> decreaseQuantity(String id, int amount) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      final newQuantity = item.quantity - amount;
      final newItem = InventoryItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: newQuantity,
        imagePath: item.imagePath,
      );
      await updateItem(id, newItem);
    }
  }
}
