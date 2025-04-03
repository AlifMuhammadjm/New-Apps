# Freelancer OS

Aplikasi manajemen untuk freelancer yang membantu mengelola proyek, klien, invoice, dan keuangan.

## Fitur

- Manajemen proyek
- Pelacakan waktu
- Pengelolaan klien
- Pembuatan dan pengiriman invoice
- Pelacakan pembayaran
- Integrasi PayPal untuk pembayaran online
- Laporan keuangan

## Teknologi yang Digunakan

- Flutter untuk pengembangan cross-platform
- Supabase sebagai backend dan database
- PayPal untuk pemrosesan pembayaran
- Stripe untuk pemrosesan pembayaran alternatif

## Persyaratan

- Flutter SDK
- Akun Supabase
- Akun PayPal Developer untuk fitur pembayaran
- Akun Stripe (untuk fitur pembayaran alternatif)

## Cara Memulai

1. Clone repositori ini
2. Jalankan `flutter pub get` untuk menginstall dependensi
3. Konfigurasikan kredensial Supabase, PayPal, dan Stripe di file konfigurasi
4. Jalankan aplikasi dengan `flutter run`

## Konfigurasi PayPal

Untuk menggunakan fitur pembayaran PayPal:

1. Daftar akun [PayPal Developer](https://developer.paypal.com/)
2. Buat aplikasi baru di PayPal Developer Dashboard
3. Dapatkan Client ID dan Secret untuk integrasi
4. Konfigurasi webhook dengan URL dari Supabase Edge Function

## Struktur Proyek

```
lib/
  ├── models/       # Model data
  │   ├── contract_model.dart
  │   ├── payment_model.dart
  │   └── user_model.dart
  ├── repositories/ # Repository untuk logika bisnis
  │   ├── auth_repository.dart
  │   ├── contract_repository.dart
  │   └── payment_repository.dart
  ├── screens/      # UI screens
  │   ├── auth/     # Layar autentikasi
  │   └── payment/  # Layar pembayaran
  ├── services/     # API dan layanan
  │   ├── supabase_service.dart
  │   └── stripe_service.dart
  └── utils/        # Utilitas dan helper
```

## Supabase Edge Functions

Proyek ini memanfaatkan Supabase Edge Functions untuk menangani webhook dari PayPal:

- `handle-paypal-webhook`: Menerima notifikasi pembayaran dari PayPal dan menyimpan ke database

## Tabel Database

Struktur tabel database Supabase yang digunakan:

```sql
-- Tabel kontrak
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  client_name TEXT,
  project_value FLOAT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel pembayaran
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users,
  amount FLOAT,
  provider TEXT, -- 'paypal', 'stripe', 'razorpay', dll
  status TEXT CHECK (status IN ('pending', 'completed', 'failed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```