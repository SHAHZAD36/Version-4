import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../sales/data/models/sale_model.dart';

class BillService {
  static Future<void> generateSingleBill(
    SaleModel sale,
    String customerName,
    List<Map<String, dynamic>> cartItems,
  ) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo not found, continue without it
    }

    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoImage != null)
              pw.Center(child: pw.Image(logoImage, width: 80)),
            pw.Center(
              child: pw.Text('CHAUDHARY TRADERS',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ),
            pw.Center(child: pw.Text('Mandi Shah Jewna, Jhang',
                style: const pw.TextStyle(fontSize: 9))),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Date: $formattedDate', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Time: $formattedTime', style: const pw.TextStyle(fontSize: 9)),
            ]),
            pw.Text('Customer: $customerName', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 8),
            pw.Divider(),
            // Items
            ...cartItems.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('${item['name']} x${item['quantity']}',
                      style: const pw.TextStyle(fontSize: 9))),
                  pw.Text('Rs. ${item['total']}', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            )),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('NET AMOUNT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.Text('Rs. ${sale.netAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ]),
            pw.Text('Payment: ${sale.paymentType}', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 16),
            pw.Center(child: pw.Text('Thank you for your business!',
                style: const pw.TextStyle(fontSize: 8))),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
