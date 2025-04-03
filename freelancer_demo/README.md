# Freelancer OS Demo

Aplikasi manajemen freelancer lengkap yang membantu freelancer mengelola kontrak, klien, faktur, dan pembayaran.

## Fitur

- **Manajemen Kontrak**: Buat, edit, lihat, dan hapus kontrak dengan klien.
- **Manajemen Klien**: Kelola informasi kontak klien.
- **Faktur**: Buat faktur otomatis dari kontrak dan kirim ke klien.
- **Dashboard**: Lihat ringkasan bisnis freelance Anda dalam satu tampilan.
- **Dokumen PDF**: Buat dokumen kontrak dan faktur dalam format PDF.
- **Escrow**: Kelola pembayaran dengan sistem escrow untuk keamanan transaksi.
- **Kalender**: Tambahkan tenggat waktu proyek ke kalender Google.
- **Notifikasi**: Dapatkan pemberitahuan tentang pembayaran, kontrak, dan lainnya.
- **Multilanguage**: Dukungan untuk bahasa Indonesia dan Inggris.

## Teknologi

- **Frontend**: Flutter
- **Backend**: Supabase
- **Basis Data**: PostgreSQL (melalui Supabase)
- **Autentikasi**: Supabase Auth
- **Penyimpanan**: Supabase Storage untuk dokumen kontrak dan faktur
- **PDF**: Generating dokumen PDF dengan package pdf

## Instalasi

1. Clone repositori:
   ```
   git clone https://github.com/username/freelancer_demo.git
   cd freelancer_demo
   ```

2. Install dependensi:
   ```
   flutter pub get
   ```

3. Buat proyek Supabase:
   - Daftar di [Supabase](https://supabase.com/)
   - Buat proyek baru
   - Jalankan skrip SQL di folder `database/schema.sql` untuk menyiapkan skema database

4. Konfigurasi Supabase:
   - Salin URL dan anon key dari pengaturan proyek Supabase
   - Perbarui nilai di file `lib/main.dart`

5. Jalankan aplikasi:
   ```
   flutter run
   ```

## Pengembangan

### Struktur Proyek

```
lib/
├── generated/          # File hasil generate lokalisasi
├── models/             # Model data (Contract, Client, Invoice, dll)
├── repositories/       # Repositori untuk manipulasi data
├── screens/            # Screen aplikasi
├── services/           # Layanan aplikasi (notifikasi, PDF, dll)
├── utils/              # Utility dan helper
└── main.dart           # Entry point aplikasi
```

### Dependensi

- `flutter_localizations`: Lokalisasi aplikasi
- `supabase_flutter`: Integrasi dengan Supabase
- `intl`: Dukungan internasionalisasi
- `uuid`: Membuat ID unik
- `pdf`: Membuat dokumen PDF
- `http`: API requests
- `path_provider`: Akses filesystem
- `url_launcher`: Membuka URL eksternal
- `fluttertoast`: Notifikasi toast
- Lainnya dapat dilihat di `pubspec.yaml`

## Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file [LICENSE](LICENSE) untuk detail.

## Pengembangan Selanjutnya

- [ ] Integrasi metode pembayaran (PayPal, Stripe)
- [ ] Manajemen waktu dan pelacakan jam kerja
- [ ] Laporan dan analitik bisnis
- [ ] Aplikasi mobile Android dan iOS
- [ ] Aplikasi desktop untuk Windows, macOS, dan Linux
