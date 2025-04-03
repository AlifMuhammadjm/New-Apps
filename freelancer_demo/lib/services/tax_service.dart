import 'dart:math';
import 'package:flutter/material.dart';

class TaxService {
  // Singleton
  static final TaxService _instance = TaxService._internal();
  factory TaxService() => _instance;
  TaxService._internal();
  
  /// Menghitung pajak berdasarkan negara dan penghasilan
  static double calculateTax(String country, double income) {
    switch (country) {
      case 'US': return income * 0.3; // Pajak AS
      case 'ID': return income * 0.11; // PPh 21 Indonesia
      case 'ES': return income * 0.21; // Pajak Spanyol
      default: return income * 0.2; // Default 20%
    }
  }
  
  /// Mendapatkan daftar negara yang didukung dan tarif pajaknya
  static Map<String, double> getSupportedCountriesWithRates() {
    return {
      'US': 0.3,
      'ID': 0.11,
      'ES': 0.21,
      'UK': 0.2,
      'DE': 0.19,
      'FR': 0.25,
      'AU': 0.33,
      'SG': 0.07,
      'JP': 0.23,
    };
  }
  
  /// Menghitung penghasilan bersih setelah pajak
  static double calculateNetIncome(String country, double income) {
    final tax = calculateTax(country, income);
    return income - tax;
  }
  
  /// Menghitung pajak progresif untuk Indonesia
  static double calculateProgressiveTaxIndonesia(double annualIncome) {
    if (annualIncome <= 60000000) {
      return annualIncome * 0.05;
    } else if (annualIncome <= 250000000) {
      return 3000000 + ((annualIncome - 60000000) * 0.15);
    } else if (annualIncome <= 500000000) {
      return 3000000 + 28500000 + ((annualIncome - 250000000) * 0.25);
    } else if (annualIncome <= 5000000000) {
      return 3000000 + 28500000 + 62500000 + ((annualIncome - 500000000) * 0.3);
    } else {
      return 3000000 + 28500000 + 62500000 + 1350000000 + ((annualIncome - 5000000000) * 0.35);
    }
  }
  
  /// Menghitung perkiraan pajak dan membuat laporan sederhana
  static Map<String, dynamic> generateTaxReport(String country, double annualIncome) {
    double taxAmount;
    double netIncome;
    double taxRate;
    String taxCategory;
    
    if (country == 'ID') {
      taxAmount = calculateProgressiveTaxIndonesia(annualIncome);
      taxRate = taxAmount / annualIncome;
      netIncome = annualIncome - taxAmount;
      
      if (annualIncome <= 60000000) {
        taxCategory = 'Rendah';
      } else if (annualIncome <= 250000000) {
        taxCategory = 'Menengah';
      } else if (annualIncome <= 500000000) {
        taxCategory = 'Menengah-Tinggi';
      } else {
        taxCategory = 'Tinggi';
      }
    } else {
      // Untuk negara lain, gunakan tarif flat
      taxRate = getSupportedCountriesWithRates()[country] ?? 0.2;
      taxAmount = annualIncome * taxRate;
      netIncome = annualIncome - taxAmount;
      
      if (taxRate <= 0.1) {
        taxCategory = 'Rendah';
      } else if (taxRate <= 0.2) {
        taxCategory = 'Menengah';
      } else if (taxRate <= 0.3) {
        taxCategory = 'Menengah-Tinggi';
      } else {
        taxCategory = 'Tinggi';
      }
    }
    
    return {
      'country': country,
      'annualIncome': annualIncome,
      'taxAmount': taxAmount,
      'netIncome': netIncome,
      'effectiveTaxRate': taxRate,
      'taxCategory': taxCategory,
    };
  }
} 