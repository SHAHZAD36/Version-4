import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportService {
  static Future<void> generateSalesReport(List<dynamic> salesData) async {
    final pdf = pw.Document();
    
    // Load the logo from assets
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final pw.MemoryImage logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logoImage, width: 80), // Logo on the left
            pw.Text("Chaudhary Traders - Sales Report", 
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        build: (context) => [
          pw.Divider(),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Customer', 'Product', 'Total'],
            data: salesData.map((s) => [s.date, s.customerName, s.product, s.amount]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF001F3F)),
          ),
        ],
      ),
    );

    // Save and preview
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}