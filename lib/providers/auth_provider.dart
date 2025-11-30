import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/currency.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  String? _profileImagePath;
  String _currencyCode = 'USD';
  String _userRole = 'Owner';
  String? _ownerEmail; // For staff members
  String? _staffId; // For staff members

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;
  String? get profileImagePath => _profileImagePath;
  String get currencyCode => _currencyCode;
  Currency get currency => CurrencyData.getCurrencyByCode(_currencyCode);
  String get userRole => _userRole;
  bool get isOwner => _userRole == 'Owner';
  bool get isStaff => _userRole == 'Staff';
  String? get ownerEmail => _ownerEmail;
  String? get staffId => _staffId;

  Future<bool> login(String identifier, String password) async {
    final db = await DatabaseHelper.instance.database;

    // Try to login as owner first
    final List<Map<String, dynamic>> userMaps = await db.query(
      'users',
      where: '(email = ? OR phone = ?) AND password = ?',
      whereArgs: [identifier, identifier, password],
    );

    if (userMaps.isNotEmpty) {
      _isAuthenticated = true;
      _userData = userMaps.first;
      _profileImagePath = _userData!['profileImagePath'];
      _currencyCode = _userData!['currencyCode'] ?? 'USD';
      _userRole = _userData!['role'] ?? 'Owner';
      _ownerEmail = null;
      _staffId = null;
      notifyListeners();
      return true;
    }

    // Try to login as staff
    final List<Map<String, dynamic>> staffMaps = await db.query(
      'staff',
      where: 'email = ? AND password = ?',
      whereArgs: [identifier, password],
    );

    if (staffMaps.isNotEmpty) {
      final staffData = staffMaps.first;
      _staffId = staffData['id'];
      _ownerEmail = staffData['ownerEmail'];

      // Load owner's business data
      final List<Map<String, dynamic>> ownerMaps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [_ownerEmail],
      );

      if (ownerMaps.isNotEmpty) {
        _isAuthenticated = true;
        _userData = ownerMaps.first;
        _profileImagePath = _userData!['profileImagePath'];
        _currencyCode = _userData!['currencyCode'] ?? 'USD';
        _userRole = 'Staff';
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  Future<bool> register(Map<String, String> data) async {
    final db = await DatabaseHelper.instance.database;

    // Check if user exists
    final List<Map<String, dynamic>> existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [data['email']],
    );

    if (existing.isNotEmpty) {
      return false; // User already exists
    }

    await db.insert('users', {
      'email': data['email']!,
      'ownerName': data['ownerName']!,
      'businessName': data['businessName']!,
      'phone': data['phone']!,
      'password': data['password']!, // In a real app, hash this!
      'profileImagePath': null,
      'currencyCode': 'USD',
      'role': 'Owner',
      'securityQuestion': data['securityQuestion'],
      'securityAnswer': data['securityAnswer'],
    });

    _isAuthenticated = true;
    _userData = {
      'email': data['email']!,
      'ownerName': data['ownerName']!,
      'businessName': data['businessName']!,
      'phone': data['phone']!,
      'profileImagePath': null,
      'currencyCode': 'USD',
      'role': 'Owner',
      'securityQuestion': data['securityQuestion'],
      'securityAnswer': data['securityAnswer'],
    };
    _userRole = 'Owner';
    _currencyCode = 'USD';
    notifyListeners();
    return true;
  }

  Future<String?> getSecurityQuestion(String email, String phone) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['securityQuestion'],
      where: 'email = ? AND phone = ?',
      whereArgs: [email, phone],
    );

    if (maps.isNotEmpty) {
      return maps.first['securityQuestion'] as String?;
    }
    return null;
  }

  Future<bool> verifySecurityAnswer(String email, String answer) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND LOWER(securityAnswer) = LOWER(?)',
      whereArgs: [email, answer],
    );
    return maps.isNotEmpty;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return count > 0;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userData = null;
    _profileImagePath = null;
    _currencyCode = 'USD';
    _userRole = 'Owner';
    _ownerEmail = null;
    _staffId = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, String> data) async {
    if (_userData == null) return;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {
        'email': data['email']!,
        'ownerName': data['ownerName']!,
        'businessName': data['businessName']!,
        'phone': data['phone']!,
        'binTin': data['binTin'],
        'street': data['street'],
        'subCity': data['subCity'],
        'city': data['city'],
        'state': data['state'],
      },
      where: 'email = ?',
      whereArgs: [_userData!['email']],
    );

    _userData = {
      ..._userData!,
      'email': data['email'],
      'ownerName': data['ownerName'],
      'businessName': data['businessName'],
      'phone': data['phone'],
      'binTin': data['binTin'],
      'street': data['street'],
      'subCity': data['subCity'],
      'city': data['city'],
      'state': data['state'],
    };
    notifyListeners();
  }

  Future<void> updateProfileImage(String imagePath) async {
    if (_userData == null) return;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {'profileImagePath': imagePath},
      where: 'email = ?',
      whereArgs: [_userData!['email']],
    );

    _profileImagePath = imagePath;
    _userData = {
      ..._userData!,
      'profileImagePath': imagePath,
    };
    notifyListeners();
  }

  Future<void> updateCurrency(String currencyCode) async {
    if (_userData == null) return;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {'currencyCode': currencyCode},
      where: 'email = ?',
      whereArgs: [_userData!['email']],
    );

    _currencyCode = currencyCode;
    _userData = {
      ..._userData!,
      'currencyCode': currencyCode,
    };
    notifyListeners();
  }

  Future<void> updateSecuritySettings(
      String securityQuestion, String securityAnswer) async {
    if (_userData == null) return;

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
      },
      where: 'email = ?',
      whereArgs: [_userData!['email']],
    );

    _userData = {
      ..._userData!,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
    };
    notifyListeners();
  }

  // Staff Management Methods
  Future<bool> addStaff(Map<String, String> staffData) async {
    if (!isOwner) return false; // Only owners can add staff

    final db = await DatabaseHelper.instance.database;

    // Check if staff email already exists
    final existing = await db.query(
      'staff',
      where: 'email = ?',
      whereArgs: [staffData['email']],
    );

    if (existing.isNotEmpty) {
      return false; // Staff with this email already exists
    }

    // Generate unique ID
    final staffId = 'staff_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('staff', {
      'id': staffId,
      'ownerEmail': _userData!['email'],
      'name': staffData['name']!,
      'email': staffData['email']!,
      'phone': staffData['phone']!,
      'password': staffData['password']!,
      'salary': double.tryParse(staffData['salary'] ?? '0') ?? 0.0,
      'createdAt': DateTime.now().toIso8601String(),
    });

    return true;
  }

  Future<List<Map<String, dynamic>>> getStaffList() async {
    if (!isOwner) return []; // Only owners can view staff

    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'staff',
      where: 'ownerEmail = ?',
      whereArgs: [_userData!['email']],
      orderBy: 'createdAt DESC',
    );
  }

  Future<bool> updateStaff(String staffId, Map<String, String> data) async {
    if (!isOwner) return false; // Only owners can update staff

    final db = await DatabaseHelper.instance.database;
    final count = await db.update(
      'staff',
      {
        'name': data['name']!,
        'email': data['email']!,
        'phone': data['phone']!,
        'salary': double.tryParse(data['salary'] ?? '0') ?? 0.0,
        if (data['password']?.isNotEmpty == true) 'password': data['password']!,
      },
      where: 'id = ? AND ownerEmail = ?',
      whereArgs: [staffId, _userData!['email']],
    );

    return count > 0;
  }

  Future<bool> deleteStaff(String staffId) async {
    if (!isOwner) return false; // Only owners can delete staff

    final db = await DatabaseHelper.instance.database;
    final count = await db.delete(
      'staff',
      where: 'id = ? AND ownerEmail = ?',
      whereArgs: [staffId, _userData!['email']],
    );

    return count > 0;
  }
}
