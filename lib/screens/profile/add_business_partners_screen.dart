import 'package:flutter/material.dart';

class Partner {
  final String id;
  String name;
  String email;
  String phone;
  String role;

  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });
}

class AddBusinessPartnersScreen extends StatefulWidget {
  const AddBusinessPartnersScreen({super.key});

  @override
  State<AddBusinessPartnersScreen> createState() =>
      _AddBusinessPartnersScreenState();
}

class _AddBusinessPartnersScreenState extends State<AddBusinessPartnersScreen> {
  final List<Partner> _partners = [];

  void _showAddPartnerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Business Partner'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role (e.g., Co-owner, Manager)',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _partners.add(Partner(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    role: roleController.text,
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partner added successfully!')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deletePartner(String id) {
    setState(() {
      _partners.removeWhere((partner) => partner.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Partners'),
      ),
      body: _partners.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No partners added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddPartnerDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Partner'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _partners.length,
              itemBuilder: (context, index) {
                final partner = _partners[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(partner.name[0].toUpperCase()),
                    ),
                    title: Text(partner.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (partner.role.isNotEmpty)
                          Text('Role: ${partner.role}'),
                        if (partner.email.isNotEmpty)
                          Text('Email: ${partner.email}'),
                        if (partner.phone.isNotEmpty)
                          Text('Phone: ${partner.phone}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePartner(partner.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _partners.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddPartnerDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
