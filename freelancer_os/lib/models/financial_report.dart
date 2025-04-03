class FinancialReport {
  final DateTime month;
  final int contractsCount;
  final double totalValue;

  FinancialReport({
    required this.month,
    required this.contractsCount,
    required this.totalValue,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      month: DateTime.parse(json['month']),
      contractsCount: json['contracts_count'],
      totalValue: (json['total_value'] is int)
          ? (json['total_value'] as int).toDouble()
          : json['total_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'contracts_count': contractsCount,
      'total_value': totalValue,
    };
  }
} 