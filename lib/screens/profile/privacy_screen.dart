import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _securityAnswerController = TextEditingController();
  String? _securityQuestion;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<AuthProvider>(context, listen: false).userData;
    if (userData != null) {
      _securityQuestion = userData['securityQuestion'];
      _securityAnswerController.text = userData['securityAnswer'] ?? '';
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updateSecuritySettings(
                _securityQuestion!, _securityAnswerController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Privacy settings updated')),
          );
          Navigator.pop(context);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Update your security question and answer to recover your account if you forget your password.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _securityQuestion,
                decoration: const InputDecoration(
                  labelText: 'Security Question',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Birth City', child: Text('Birth City')),
                  DropdownMenuItem(
                      value: 'Nick Name', child: Text('Nick Name')),
                  DropdownMenuItem(
                      value: 'First School', child: Text('First School')),
                ],
                onChanged: (value) {
                  setState(() {
                    _securityQuestion = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _securityAnswerController,
                decoration: const InputDecoration(
                  labelText: 'Security Answer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
