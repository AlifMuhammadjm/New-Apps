import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Kelas lokalisasi sederhana
class S {
  static S? _current;

  static S get current {
    _current ??= S();
    return _current!;
  }

  // Teks Umum
  String get appName => Intl.message('Freelancer OS', name: 'appName');
  String get loading => Intl.message('Memuat...', name: 'loading');
  String get error => Intl.message('Terjadi kesalahan', name: 'error');
  String get success => Intl.message('Berhasil', name: 'success');
  String get cancel => Intl.message('Batal', name: 'cancel');
  String get save => Intl.message('Simpan', name: 'save');
  String get delete => Intl.message('Hapus', name: 'delete');
  String get edit => Intl.message('Edit', name: 'edit');
  String get ok => Intl.message('OK', name: 'ok');
  String get yes => Intl.message('Ya', name: 'yes');
  String get no => Intl.message('Tidak', name: 'no');

  // Teks Login/Register
  String get welcomeMessage => Intl.message('Selamat Datang di Freelancer OS', name: 'welcomeMessage');
  String get email => Intl.message('Email', name: 'email');
  String get password => Intl.message('Password', name: 'password');
  String get login => Intl.message('Masuk', name: 'login');
  String get register => Intl.message('Daftar', name: 'register');
  String get forgotPassword => Intl.message('Lupa Password?', name: 'forgotPassword');
  String get dontHaveAccount => Intl.message('Belum punya akun?', name: 'dontHaveAccount');
  String get alreadyHaveAccount => Intl.message('Sudah punya akun?', name: 'alreadyHaveAccount');
  String get createAccount => Intl.message('Buat Akun', name: 'createAccount');

  // Teks Dashboard
  String get dashboard => Intl.message('Dashboard', name: 'dashboard');
  String get welcome => Intl.message('Selamat Datang', name: 'welcome');
  String get activeContracts => Intl.message('Kontrak Aktif', name: 'activeContracts');
  String get completedContracts => Intl.message('Kontrak Selesai', name: 'completedContracts');
  String get pendingInvoices => Intl.message('Faktur Tertunda', name: 'pendingInvoices');
  String get clients => Intl.message('Klien', name: 'clients');
  String get income => Intl.message('Pendapatan', name: 'income');
  String get monthlyIncome => Intl.message('Pendapatan Bulan Ini', name: 'monthlyIncome');

  // Teks Kontrak
  String get contracts => Intl.message('Kontrak', name: 'contracts');
  String get contractsList => Intl.message('Daftar Kontrak', name: 'contractsList');
  String get contractDetails => Intl.message('Detail Kontrak', name: 'contractDetails');
  String get newContract => Intl.message('Kontrak Baru', name: 'newContract');
  String get projectName => Intl.message('Nama Proyek', name: 'projectName');
  String get clientName => Intl.message('Nama Klien', name: 'clientName');
  String get contractValue => Intl.message('Nilai Kontrak', name: 'contractValue');
  String get startDate => Intl.message('Tanggal Mulai', name: 'startDate');
  String get endDate => Intl.message('Tanggal Selesai', name: 'endDate');
  String get status => Intl.message('Status', name: 'status');
  String get description => Intl.message('Deskripsi', name: 'description');
  String get active => Intl.message('Aktif', name: 'active');
  String get completed => Intl.message('Selesai', name: 'completed');
  String get canceled => Intl.message('Dibatalkan', name: 'canceled');
  String get document => Intl.message('Dokumen', name: 'document');
  String get uploadDocument => Intl.message('Unggah Dokumen', name: 'uploadDocument');
  String get viewDocument => Intl.message('Lihat Dokumen', name: 'viewDocument');
  String get createPdf => Intl.message('Buat PDF', name: 'createPdf');
  String get markAsCompleted => Intl.message('Tandai sebagai Selesai', name: 'markAsCompleted');
  String get cancelContract => Intl.message('Batalkan Kontrak', name: 'cancelContract');
  String get reactivateContract => Intl.message('Aktifkan Kembali', name: 'reactivateContract');

  // Teks Faktur
  String get invoices => Intl.message('Faktur', name: 'invoices');
  String get invoicesList => Intl.message('Daftar Faktur', name: 'invoicesList');
  String get invoiceDetails => Intl.message('Detail Faktur', name: 'invoiceDetails');
  String get newInvoice => Intl.message('Faktur Baru', name: 'newInvoice');
  String get invoiceNumber => Intl.message('Nomor Faktur', name: 'invoiceNumber');
  String get amount => Intl.message('Jumlah', name: 'amount');
  String get issueDate => Intl.message('Tanggal Penerbitan', name: 'issueDate');
  String get dueDate => Intl.message('Tanggal Jatuh Tempo', name: 'dueDate');
  String get paid => Intl.message('Dibayar', name: 'paid');
  String get unpaid => Intl.message('Belum Dibayar', name: 'unpaid');
  String get markAsPaid => Intl.message('Tandai sebagai Dibayar', name: 'markAsPaid');
  
  // Teks Klien
  String get clientsList => Intl.message('Daftar Klien', name: 'clientsList');
  String get clientDetails => Intl.message('Detail Klien', name: 'clientDetails');
  String get newClient => Intl.message('Klien Baru', name: 'newClient');
  String get company => Intl.message('Perusahaan', name: 'company');
  String get phone => Intl.message('Telepon', name: 'phone');
  String get address => Intl.message('Alamat', name: 'address');
  
  // Teks Pembayaran dan Escrow
  String get payments => Intl.message('Pembayaran', name: 'payments');
  String get escrow => Intl.message('Escrow', name: 'escrow');
  String get holdEscrow => Intl.message('Tahan Pembayaran', name: 'holdEscrow');
  String get releaseEscrow => Intl.message('Lepaskan Pembayaran', name: 'releaseEscrow');
  String get refundEscrow => Intl.message('Kembalikan Pembayaran', name: 'refundEscrow');
  String get held => Intl.message('Ditahan', name: 'held');
  String get released => Intl.message('Dilepaskan', name: 'released');
  String get refunded => Intl.message('Dikembalikan', name: 'refunded');
  
  // Teks Pengaturan
  String get settings => Intl.message('Pengaturan', name: 'settings');
  String get profile => Intl.message('Profil', name: 'profile');
  String get language => Intl.message('Bahasa', name: 'language');
  String get theme => Intl.message('Tema', name: 'theme');
  String get notifications => Intl.message('Notifikasi', name: 'notifications');
  String get logout => Intl.message('Keluar', name: 'logout');
} 