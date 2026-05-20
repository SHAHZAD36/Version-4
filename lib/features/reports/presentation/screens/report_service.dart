import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportService {
  static Future<void> generateSalesReport(List<Map<String, dynamic>> salesData) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo not found, continue without it
    }

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logoImage != null) pw.Image(logoImage, width: 60),
            pw.Text('Chaudhary Traders - Sales Report',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        build: (context) => [
          pw.Divider(),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Customer', 'Amount', 'Type'],
            data: salesData.map((s) => [
              s['date'] ?? '',
              s['shop_name'] ?? '',
              'Rs. ${s['net_amount'] ?? 0}',
              s['payment_type'] ?? '',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            // Fixed: use PdfColors instead of PdfColor.fromInt
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
