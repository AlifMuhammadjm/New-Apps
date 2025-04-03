import 'package:flutter/material.dart';

/// Layanan untuk integrasi dengan OpenAI API
class OpenAIService {
  /// API key untuk OpenAI
  String? _apiKey;

  /// Model yang akan digunakan (mis. 'gpt-3.5-turbo')
  String _model = 'gpt-3.5-turbo';

  /// Inisialisasi layanan OpenAI
  Future<void> initialize({String? apiKey}) async {
    _apiKey = apiKey;
    // Dalam implementasi nyata, ini akan memvalidasi API key
    print('OpenAI Service diinisialisasi');
  }

  /// Menghasilkan teks dari prompt yang diberikan
  Future<String> generateText({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    // Contoh implementasi - dalam aplikasi nyata akan memanggil API OpenAI
    try {
      // Simulasi delay untuk request API
      await Future.delayed(Duration(seconds: 1));
      
      // Return teks contoh berdasarkan prompt
      if (prompt.contains('kontrak')) {
        return 'KONTRAK KERJA FREELANCE\n\nAntara:\n[Nama Klien]\ndan\n[Nama Freelancer]\n\n1. RUANG LINGKUP PEKERJAAN\nFreelancer akan menyediakan layanan berikut: [deskripsi pekerjaan]\n\n2. JANGKA WAKTU\nPeriode kontrak: [tanggal mulai] hingga [tanggal selesai]\n\n3. PEMBAYARAN\nBiaya: [jumlah]\nMetode pembayaran: [metode]\nJadwal pembayaran: [jadwal]\n\n4. HAK KEKAYAAN INTELEKTUAL\nSemua karya yang dibuat selama kontrak ini akan menjadi milik Klien setelah pembayaran penuh diterima.\n\n5. KERAHASIAAN\nFreelancer setuju untuk menjaga kerahasiaan semua informasi yang diberikan oleh Klien.\n\n6. PENGAKHIRAN\nKontrak ini dapat diakhiri oleh salah satu pihak dengan pemberitahuan tertulis 7 hari sebelumnya.\n\nDitandatangani:';
      } else if (prompt.contains('invoice')) {
        return 'INVOICE\n\nDari: [Nama Freelancer]\nUntuk: [Nama Klien]\n\nNo. Invoice: INV-001\nTanggal: [tanggal hari ini]\nJatuh Tempo: [14 hari dari sekarang]\n\nDeskripsi Layanan:\n[Deskripsi proyek] - [Jumlah]\n\nTotal: [Jumlah]\n\nMetode Pembayaran:\n[Detil pembayaran]';
      } else {
        return 'Saya dapat membantu Anda membuat kontrak, invoice, atau dokumen lain untuk kebutuhan freelance Anda. Silakan berikan detail spesifik tentang apa yang Anda butuhkan.';
      }
    } catch (e) {
      print('Error generating text: $e');
      return 'Maaf, terjadi kesalahan saat menghasilkan teks.';
    }
  }

  /// Widget untuk generate kontrak dengan AI
  Widget buildContractGeneratorWidget({
    required BuildContext context,
    required Function(String) onContractGenerated,
  }) {
    final TextEditingController promptController = TextEditingController();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generator Kontrak AI',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: promptController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Proyek',
                hintText: 'Jelaskan proyek yang akan dikerjakan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await generateText(
                  prompt: 'Buat kontrak freelance untuk: ${promptController.text}',
                );
                onContractGenerated(result);
              },
              child: const Text('Generate Kontrak'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> generateContractTemplate({
    required String projectType,
    String? clientName,
    String? freelancerName,
    double? projectValue,
    String? additionalDetails,
  }) async {
    final key = await apiKey;
    if (key == null) {
      throw Exception('API key OpenAI belum diatur. Silakan atur di pengaturan.');
    }

    final prompt = '''
Buat kontrak ${projectType} untuk klien bernama ${clientName ?? '[NAMA KLIEN]'} 
dan freelancer bernama ${freelancerName ?? '[NAMA FREELANCER]'} 
dengan nilai proyek ${projectValue != null ? 'Rp ${projectValue.toStringAsFixed(0)}' : '[NILAI PROYEK]'}.
${additionalDetails != null ? 'Detail tambahan: $additionalDetails' : ''}
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': 'Anda adalah asisten yang membantu membuat dokumen kontrak profesional untuk freelancer.'},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        throw Exception('Gagal mendapatkan respons dari OpenAI: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat menghubungi OpenAI API: $e');
    }
  }

  Future<String?> get apiKey async {
    if (_apiKey != null) return _apiKey;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey);
  }
} 