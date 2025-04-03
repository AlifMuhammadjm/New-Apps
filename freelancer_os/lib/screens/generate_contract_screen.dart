import 'package:flutter/material.dart';
import 'package:freelancer_os/services/openai_service.dart';

class GenerateContractScreen extends StatefulWidget {
  const GenerateContractScreen({super.key});

  @override
  State<GenerateContractScreen> createState() => _GenerateContractScreenState();
}

class _GenerateContractScreenState extends State<GenerateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectTypeController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _freelancerNameController = TextEditingController();
  final _projectValueController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  
  String? _generatedContract;
  bool _isLoading = false;

  @override
  void dispose() {
    _projectTypeController.dispose();
    _clientNameController.dispose();
    _freelancerNameController.dispose();
    _projectValueController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _generateContract() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _generatedContract = null;
      });

      try {
        final openAIService = OpenAIService();
        
        final contract = await openAIService.generateContractTemplate(
          projectType: _projectTypeController.text,
          clientName: _clientNameController.text,
          freelancerName: _freelancerNameController.text,
          projectValue: double.tryParse(_projectValueController.text),
          additionalDetails: _additionalDetailsController.text.isNotEmpty 
              ? _additionalDetailsController.text 
              : null,
        );

        setState(() {
          _generatedContract = contract;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Kontrak dengan AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _projectTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Proyek (Web Design, Logo, Mobile App, dll)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan jenis proyek';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Klien',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _freelancerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Freelancer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _projectValueController,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Proyek (Rp)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _additionalDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Detail Tambahan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generateContract,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Buat Kontrak dengan AI', style: TextStyle(fontSize: 16)),
                ),
                if (_generatedContract != null) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Kontrak yang Dihasilkan:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_generatedContract!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implementasi untuk menyimpan kontrak
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kontrak disimpan')),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Kontrak'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implementasi untuk berbagi kontrak
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kontrak dibagikan')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Bagikan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 