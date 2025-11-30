import 'package:flutter/material.dart';
import '../providers/order_provider.dart';
import '../utils/invoice_generator.dart';

class InvoicePreviewDialog extends StatefulWidget {
  final Order order;
  final Map<String, dynamic> businessInfo;
  final String currencyName;

  const InvoicePreviewDialog({
    super.key,
    required this.order,
    required this.businessInfo,
    required this.currencyName,
  });

  @override
  State<InvoicePreviewDialog> createState() => _InvoicePreviewDialogState();
}

class _InvoicePreviewDialogState extends State<InvoicePreviewDialog> {
  String _selectedPaymentMethod = 'Cash';
  bool _includeBinTin = true;
  bool _isGenerating = false;

  final List<String> _paymentMethods = [
    'Cash',
    'Card',
    'Mobile Banking',
    'Bank Transfer',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invoice Preview'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Customer', widget.order.customer.name),
                      _buildInfoRow('Phone', widget.order.customer.phone),
                      _buildInfoRow(
                        'Invoice #',
                        widget.order.id.substring(0, 8),
                      ),
                      _buildInfoRow(
                        'Total Amount',
                        '${widget.currencyName} ${widget.order.total.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),
                      Text(
                        'Items (${widget.order.items.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...widget.order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child:
                                    Text('${item.itemName} x${item.quantity}'),
                              ),
                              Text(
                                '${widget.currencyName} ${item.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Method Selection
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // BIN/TIN Option
              CheckboxListTile(
                title: const Text('Include BIN/TIN on invoice'),
                subtitle: Text(
                  widget.businessInfo['binTin']?.isNotEmpty == true
                      ? 'BIN/TIN: ${widget.businessInfo['binTin']}'
                      : 'No BIN/TIN set in profile',
                ),
                value: _includeBinTin,
                onChanged: widget.businessInfo['binTin']?.isNotEmpty == true
                    ? (value) {
                        setState(() {
                          _includeBinTin = value!;
                        });
                      }
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateInvoice,
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print),
          label: Text(_isGenerating ? 'Generating...' : 'Print Invoice'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _generateInvoice() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await InvoiceGenerator.generateAndPrintInvoice(
        widget.order,
        widget.businessInfo,
        widget.currencyName,
        paymentMethod: _selectedPaymentMethod,
        includeBinTin: _includeBinTin,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating invoice: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
