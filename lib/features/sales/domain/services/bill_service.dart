import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BillService {
  static Future<void> generateSingleBill(dynamic sale) async {
    final pdf = pw.Document();
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final pw.MemoryImage logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Formatting date and time
    String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Standard receipt format
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlign.start,
          children: [
            pw.Center(child: pw.Image(logoImage, width: 100)),
            pw.Center(child: pw.Text("CHAUDHARY TRADERS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Divider(),
            pw.Text("Date: $formattedDate"),
            pw.Text("Time: $formattedTime"),
            pw.Text("Customer: ${sale.customerName}"),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              data: [
                ['Item', 'Qty', 'Total'],
                [sale.productName, '${sale.quantity}', '${sale.totalPrice}'],
              ],
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Total: RS ${sale.totalPrice}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text("Thank you for your business!", style: pw.TextStyle(fontSize: 8))),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}