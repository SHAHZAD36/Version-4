import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportService {
  static final _fmt = NumberFormat('#,##0');

  // ===== PDF REPORTS =====
  static Future<void> generateSalesPDF(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      header: (_) => _pdfHeader('Sales Report'),
      build: (_) => [
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Customer', 'Amount', 'Type'],
          data: data.map((s) => [
            s['date'] ?? '',
            s['shop_name'] ?? 'N/A',
            'Rs. ${_fmt.format(s['net_amount'] ?? 0)}',
            s['payment_type'] ?? '',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
          cellAlignments: {0: pw.Alignment.centerLeft},
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Total: Rs. ${_fmt.format(data.fold(0.0, (s, r) => s + ((r['net_amount'] as num?)?.toDouble() ?? 0)))}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static Future<void> generatePurchasesPDF(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      header: (_) => _pdfHeader('Purchase Report'),
      build: (_) => [
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Supplier', 'Product ID', 'Qty', 'Total'],
          data: data.map((p) => [
            p['date'] ?? '',
            p['supplier_name'] ?? 'N/A',
            '${p['product_id'] ?? ''}',
            '${p['quantity'] ?? ''}',
            'Rs. ${_fmt.format(p['total_cost'] ?? 0)}',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.orange800),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Total: Rs. ${_fmt.format(data.fold(0.0, (s, r) => s + ((r['total_cost'] as num?)?.toDouble() ?? 0)))}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static Future<void> generateExpensesPDF(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      header: (_) => _pdfHeader('Expense Report'),
      build: (_) => [
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Category', 'Description', 'Amount'],
          data: data.map((e) => [
            e['date'] ?? '',
            e['category'] ?? '',
            e['description'] ?? '',
            'Rs. ${_fmt.format(e['amount'] ?? 0)}',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Total: Rs. ${_fmt.format(data.fold(0.0, (s, r) => s + ((r['amount'] as num?)?.toDouble() ?? 0)))}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static Future<void> generateStockPDF(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      header: (_) => _pdfHeader('Stock Report'),
      build: (_) => [
        pw.TableHelper.fromTextArray(
          headers: ['Product', 'Brand', 'Stock', 'Min Level', 'Sale Price', 'Value'],
          data: data.map((p) => [
            p['name'] ?? '',
            p['brand'] ?? '',
            '${p['current_stock'] ?? 0}',
            '${p['min_stock_level'] ?? 0}',
            'Rs. ${_fmt.format(p['sale_price'] ?? 0)}',
            'Rs. ${_fmt.format(((p['current_stock'] as num?)?.toDouble() ?? 0) * ((p['sale_price'] as num?)?.toDouble() ?? 0))}',
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.purple800),
        ),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  // ===== EXCEL REPORTS =====
  static Future<void> generateSalesExcel(List<Map<String, dynamic>> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];
    _addExcelHeaders(sheet, ['Date', 'Customer', 'Amount', 'Discount', 'Net Amount', 'Type']);
    for (var row in data) {
      sheet.appendRow([
        TextCellValue(row['date']?.toString() ?? ''),
        TextCellValue(row['shop_name']?.toString() ?? 'N/A'),
        DoubleCellValue((row['total_amount'] as num?)?.toDouble() ?? 0),
        DoubleCellValue((row['discount'] as num?)?.toDouble() ?? 0),
        DoubleCellValue((row['net_amount'] as num?)?.toDouble() ?? 0),
        TextCellValue(row['payment_type']?.toString() ?? ''),
      ]);
    }
    await _saveAndShareExcel(excel, 'Sales_Report');
  }

  static Future<void> generateExpensesExcel(List<Map<String, dynamic>> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Expenses Report'];
    _addExcelHeaders(sheet, ['Date', 'Category', 'Description', 'Amount']);
    for (var row in data) {
      sheet.appendRow([
        TextCellValue(row['date']?.toString() ?? ''),
        TextCellValue(row['category']?.toString() ?? ''),
        TextCellValue(row['description']?.toString() ?? ''),
        DoubleCellValue((row['amount'] as num?)?.toDouble() ?? 0),
      ]);
    }
    await _saveAndShareExcel(excel, 'Expenses_Report');
  }

  static Future<void> generateStockExcel(List<Map<String, dynamic>> data) async {
    final excel = Excel.createExcel();
    final sheet = excel['Stock Report'];
    _addExcelHeaders(sheet, ['Product', 'Brand', 'Current Stock', 'Min Level', 'Purchase Price', 'Sale Price', 'Stock Value']);
    for (var row in data) {
      final stock = (row['current_stock'] as num?)?.toDouble() ?? 0;
      final price = (row['sale_price'] as num?)?.toDouble() ?? 0;
      sheet.appendRow([
        TextCellValue(row['name']?.toString() ?? ''),
        TextCellValue(row['brand']?.toString() ?? ''),
        DoubleCellValue(stock),
        DoubleCellValue((row['min_stock_level'] as num?)?.toDouble() ?? 0),
        DoubleCellValue((row['purchase_price'] as num?)?.toDouble() ?? 0),
        DoubleCellValue(price),
        DoubleCellValue(stock * price),
      ]);
    }
    await _saveAndShareExcel(excel, 'Stock_Report');
  }

  // ===== HELPERS =====
  static pw.Widget _pdfHeader(String title) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('CHAUDHARY TRADERS',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.Text(title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
      ]),
      pw.Text('Generated: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 9)),
      pw.Divider(),
    ]);
  }

  static void _addExcelHeaders(Sheet sheet, List<String> headers) {
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
  }

  static Future<void> _saveAndShareExcel(Excel excel, String name) async {
    try {
      final bytes = excel.save();
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: '$name - Chaudhary Traders');
    } catch (e) {
      debugPrint('Excel error: $e');
    }
  }
}
