import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/category_stat.dart';
import '../constants/categories.dart';

class ExportService {
  // Export to RFC 4180 CSV
  static Future<void> exportToCsv(List<Expense> expenses) async {
    final List<List<dynamic>> rows = [];
    // Header
    rows.add([
      'ID',
      'Title',
      'Amount',
      'Category',
      'Date',
      'Payment Method',
      'Notes'
    ]);

    for (final exp in expenses) {
      final cat = AppCategories.getById(exp.categoryId).name;
      rows.add([
        exp.id ?? '',
        exp.title,
        exp.amount.toStringAsFixed(2),
        cat,
        DateFormat('yyyy-MM-dd HH:mm').format(exp.date),
        exp.paymentMethod,
        exp.notes ?? '',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('/ExpenseFlow_Export_.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'ExpenseFlow CSV Data Export ()',
    );
  }

  // Export to Professional Formatted PDF Report
  static Future<void> exportToPdf({
    required List<Expense> expenses,
    required List<CategoryStat> categoryStats,
    required double totalSpent,
    required String currencySymbol,
    DateTimeRange? dateRange,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateRangeStr = dateRange != null
        ? ' - '
        : 'All-Time Financial Overview';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossContent: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ExpenseFlow Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      dateRangeStr,
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossContent: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated on:',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      DateFormat('MMM d, yyyy • HH:mm').format(now),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey200),
            pw.SizedBox(height: 16),

            // Executive Summary KPIs
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfKpi('Total Spend', ''),
                  _buildPdfKpi('Transactions', ' records'),
                  _buildPdfKpi(
                    'Average Ticket',
                    expenses.isNotEmpty
                        ? ''
                        : ' 0.00',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Category Breakdown Section
            if (categoryStats.isNotEmpty) ...[
              pw.Text(
                'Category Breakdown',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Category', 'Transactions', 'Percentage', 'Subtotal'],
                data: categoryStats.map((cat) {
                  return [
                    cat.name,
                    '',
                    '%',
                    '',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 24),
            ],

            // Itemized Transaction Ledger
            pw.Text(
              'Itemized Transaction Ledger',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Item / Title', 'Category', 'Method', 'Amount'],
              data: expenses.map((exp) {
                final cat = AppCategories.getById(exp.categoryId).name;
                return [
                  DateFormat('yyyy-MM-dd').format(exp.date),
                  exp.title,
                  cat,
                  exp.paymentMethod,
                  '',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                4: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ExpenseFlow_Report_.pdf',
    );
  }

  static pw.Widget _buildPdfKpi(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
        ),
      ],
    );
  }
}
