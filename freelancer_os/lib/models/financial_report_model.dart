class FinancialReport {
  final double totalIncome;
  final int paidInvoices;
  final int pendingInvoices;
  final DateTime startDate;
  final DateTime endDate;

  FinancialReport({
    required this.totalIncome,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.startDate,
    required this.endDate,
  });

  // Membuat objek FinancialReport dari Map
  factory FinancialReport.fromMap(Map<String, dynamic> map) {
    return FinancialReport(
      totalIncome: (map['total_income'] is num) 
          ? (map['total_income'] as num).toDouble() 
          : double.parse(map['total_income'].toString()),
      paidInvoices: (map['paid_invoices'] is num) 
          ? (map['paid_invoices'] as num).toInt() 
          : int.parse(map['paid_invoices'].toString()),
      pendingInvoices: (map['pending_invoices'] is num) 
          ? (map['pending_invoices'] as num).toInt() 
          : int.parse(map['pending_invoices'].toString()),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
    );
  }

  // Konversi FinancialReport menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'total_income': totalIncome,
      'paid_invoices': paidInvoices,
      'pending_invoices': pendingInvoices,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  // Menghitung jumlah total invoice
  int get totalInvoices => paidInvoices + pendingInvoices;

  // Menghitung persentase invoice yang telah dibayar
  double get paidInvoicePercentage => 
      totalInvoices > 0 ? (paidInvoices / totalInvoices) * 100 : 0;

  // Menghitung pendapatan rata-rata per invoice yang dibayar
  double get averageIncomePerPaidInvoice =>
      paidInvoices > 0 ? totalIncome / paidInvoices : 0;
      
  // Format bulan dan tahun dari startDate
  String get periodMonth => 
      '${startDate.month}/${startDate.year}';
} 