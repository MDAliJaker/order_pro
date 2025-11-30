import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';

class InvoiceGenerator {
  static Future<void> generateAndPrintInvoice(
    Order order,
    Map<String, dynamic> businessInfo,
    String currencyName, {
    String paymentMethod = 'Cash',
    bool includeBinTin = true,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      businessInfo['businessName'] ?? 'Business Name',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        font: font,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '${businessInfo['street'] ?? ''}, ${businessInfo['subCity'] ?? ''}, ${businessInfo['city'] ?? ''}, ${businessInfo['state'] ?? ''}',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text(
                      'Phone: ${businessInfo['phone'] ?? ''} | Email: ${businessInfo['email'] ?? ''}',
                      style: pw.TextStyle(font: font),
                    ),
                    if (includeBinTin &&
                        businessInfo['binTin'] != null &&
                        businessInfo['binTin']!.isNotEmpty)
                      pw.Text(
                        'BIN/TIN: ${businessInfo['binTin']}',
                        style: pw.TextStyle(font: font),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Customer Info & Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Customer: ${order.customer.name}',
                          style: pw.TextStyle(
                              font: font, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Phone: ${order.customer.phone}',
                          style: pw.TextStyle(font: font)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${order.id.substring(0, 8)}',
                          style: pw.TextStyle(font: font)),
                      pw.Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(order.createdAt)}',
                        style: pw.TextStyle(font: font),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Items Table
              pw.TableHelper.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
                headers: ['SL', 'Item Name', 'Qty', 'Price', 'Total'],
                data: List<List<String>>.generate(
                  order.items.length,
                  (index) {
                    final item = order.items[index];
                    return [
                      (index + 1).toString(),
                      item.itemName,
                      item.quantity.toString(),
                      '$currencyName ${item.price.toStringAsFixed(2)}',
                      '$currencyName ${item.total.toStringAsFixed(2)}',
                    ];
                  },
                ),
              ),
              pw.Divider(),

              // Totals
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Subtotal: $currencyName ${order.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.Text(
                      'VAT (0%): $currencyName ${0.00.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Grand Total: $currencyName ${order.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        font: font,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Payment Method
              pw.Text(
                'Payment Method: $paymentMethod',
                style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic),
              ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(font: font, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Generate filename with invoice number and business name
    final invoiceNumber = order.id.substring(0, 8);
    final businessName = (businessInfo['businessName'] ?? 'Business')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filename = 'Invoice_${invoiceNumber}_$businessName.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: filename,
    );
  }
}
