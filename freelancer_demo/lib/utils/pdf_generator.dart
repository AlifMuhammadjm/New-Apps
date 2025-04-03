import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/contract.dart';
import '../models/invoice.dart';

class PdfGenerator {
  // Singleton
  static final PdfGenerator _instance = PdfGenerator._internal();
  factory PdfGenerator() => _instance;
  PdfGenerator._internal();

  // Membuat dokumen PDF untuk kontrak
  Future<File> generateContractPdf(Contract contract) async {
    final pdf = pw.Document();
    
    // Untuk demo, kita buat dokumen PDF sangat sederhana
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('KONTRAK KERJA', 
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)
              ),
              pw.SizedBox(height: 20),
              pw.Text('Nomor Kontrak: ${contract.id}'),
              pw.SizedBox(height: 20),
              pw.Text('PIHAK PERTAMA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Freelancer OS Demo'),
              pw.SizedBox(height: 10),
              pw.Text('PIHAK KEDUA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(contract.clientName),
              pw.SizedBox(height: 20),
              pw.Text('DETAIL PROYEK', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('Nama Proyek: ${contract.projectName}'),
              pw.Text('Tanggal Mulai: ${DateFormat('dd/MM/yyyy').format(contract.startDate)}'),
              pw.Text('Tanggal Selesai: ${DateFormat('dd/MM/yyyy').format(contract.endDate)}'),
              pw.Text('Nilai Kontrak: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(contract.value)}'),
              pw.SizedBox(height: 20),
              pw.Text('DESKRIPSI PEKERJAAN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(contract.description),
              pw.SizedBox(height: 20),
              pw.Text('Dokumen ini dibuat pada ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
              pw.Expanded(child: pw.SizedBox()),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Dokumen ini dibuat oleh Freelancer OS Demo'),
              ),
            ],
          );
        }
      )
    );
    
    // Simpan dokumen ke file
    return _saveDocument(pdf, 'kontrak_${contract.id}.pdf');
  }

  // Membuat dokumen PDF untuk faktur
  Future<File> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();
    
    // Untuk demo, kita buat dokumen PDF sangat sederhana
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FAKTUR', 
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)
              ),
              pw.SizedBox(height: 20),
              pw.Text('Nomor Faktur: ${invoice.invoiceNumber}'),
              pw.SizedBox(height: 20),
              pw.Text('KEPADA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.clientName),
              pw.SizedBox(height: 20),
              pw.Text('DETAIL FAKTUR', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('Tanggal Faktur: ${DateFormat('dd/MM/yyyy').format(invoice.issueDate)}'),
              pw.Text('Tanggal Jatuh Tempo: ${DateFormat('dd/MM/yyyy').format(invoice.dueDate)}'),
              pw.Text('Jumlah: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(invoice.amount)}'),
              pw.SizedBox(height: 20),
              pw.Text('PEMBAYARAN KE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('Bank: Bank XYZ'),
              pw.Text('No. Rekening: 1234567890'),
              pw.Text('Atas Nama: Freelancer OS Demo'),
              pw.SizedBox(height: 20),
              pw.Text('Faktur ini dibuat pada ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
              pw.Expanded(child: pw.SizedBox()),
              pw.Divider(),
              pw.Center(
                child: pw.Text('Dokumen ini dibuat oleh Freelancer OS Demo'),
              ),
            ],
          );
        }
      )
    );
    
    // Simpan dokumen ke file
    return _saveDocument(pdf, 'faktur_${invoice.invoiceNumber}.pdf');
  }

  // Menyimpan dokumen PDF ke file
  Future<File> _saveDocument(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  // Membuka file PDF
  Future<void> openPdf(File file) async {
    final url = file.path;
    
    if (kIsWeb) {
      // Implementasi khusus untuk web bisa ditambahkan di sini
      debugPrint('Membuka PDF pada web tidak didukung dalam demo ini');
    } else {
      await OpenFile.open(url);
    }
  }
} 