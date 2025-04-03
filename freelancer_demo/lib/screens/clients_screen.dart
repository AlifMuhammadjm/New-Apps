import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../services/notification_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final ClientService _clientService = ClientService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSearching = false;
  List<Client> _clients = [];
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadClients() {
    setState(() {
      _isLoading = true;
    });

    try {
      final clients = _clientService.getAllClients();
      setState(() {
        _clients = clients;
        _filteredClients = clients;
        _isLoading = false;
      });
    } catch (e) {
      _notificationService.showFlutterToast('Gagal memuat daftar klien: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterClients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredClients = _clients;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredClients = _clientService.searchClients(query);
    });
  }

  Future<void> _showClientFormDialog({Client? client}) async {
    final isEditing = client != null;
    final nameController = TextEditingController(text: client?.name ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final phoneController = TextEditingController(text: client?.phoneNumber ?? '');
    final companyController = TextEditingController(text: client?.companyName ?? '');
    final addressController = TextEditingController(text: client?.address ?? '');
    final notesController = TextEditingController(text: client?.notes ?? '');
    
    String? profilePictureUrl = client?.profilePictureUrl;
    File? imageFile;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            Future<void> _selectImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              
              if (image != null) {
                setStateDialog(() {
                  imageFile = File(image.path);
                });
              }
            }
            
            return AlertDialog(
              title: Text(isEditing ? 'Edit Klien' : 'Tambah Klien Baru'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: _selectImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!) as ImageProvider
                              : (profilePictureUrl != null
                                  ? NetworkImage(profilePictureUrl!) as ImageProvider
                                  : null),
                          child: imageFile == null && profilePictureUrl == null
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Pilih Foto'),
                        onPressed: _selectImage,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Klien*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email*',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Perusahaan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(isEditing ? 'Simpan' : 'Tambah'),
                  onPressed: () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty) {
                      _notificationService.showFlutterToast('Nama dan email wajib diisi');
                      return;
                    }

                    try {
                      // Untuk demo, kita tidak benar-benar mengunggah gambar
                      // tapi tetap menunjukkan foto dipilih
                      final String? tempProfileUrl = imageFile != null 
                          ? 'dummy_url_for_demo' 
                          : profilePictureUrl;

                      if (isEditing) {
                        // Update klien
                        final updatedClient = client!.copyWith(
                          name: nameController.text,
                          email: emailController.text,
                          phoneNumber: phoneController.text,
                          companyName: companyController.text,
                          address: addressController.text,
                          notes: notesController.text,
                          profilePictureUrl: tempProfileUrl,
                          updatedAt: DateTime.now(),
                        );
                        _clientService.updateClient(updatedClient);
                        _notificationService.showFlutterToast('Klien berhasil diperbarui');
                      } else {
                        // Buat klien baru
                        _clientService.addClient(
                          name: nameController.text,
                          email: emailController.text,
                          phoneNumber: phoneController.text,
                          companyName: companyController.text,
                          address: addressController.text,
                          notes: notesController.text,
                          profilePictureUrl: tempProfileUrl,
                        );
                        _notificationService.showFlutterToast('Klien baru berhasil ditambahkan');
                      }

                      Navigator.of(context).pop();
                      _loadClients();
                    } catch (e) {
                      _notificationService.showFlutterToast('Terjadi kesalahan: ${e.toString()}');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteClient(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus klien ${client.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        _clientService.deleteClient(client.id);
        _notificationService.showFlutterToast('Klien berhasil dihapus');
        _loadClients();
      } catch (e) {
        _notificationService.showFlutterToast('Gagal menghapus klien: ${e.toString()}');
      }
    }
  }

  Future<void> _showClientDetails(Client client) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(client.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: client.profilePictureUrl != null
                        ? NetworkImage(client.profilePictureUrl!) as ImageProvider
                        : null,
                    child: client.profilePictureUrl == null
                        ? Text(client.initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                if (client.companyName != null && client.companyName!.isNotEmpty) ...[
                  const Text('Perusahaan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(client.companyName!),
                  const SizedBox(height: 8),
                ],
                const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(client.email),
                const SizedBox(height: 8),
                if (client.phoneNumber != null && client.phoneNumber!.isNotEmpty) ...[
                  const Text('Telepon:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(client.phoneNumber!),
                  const SizedBox(height: 8),
                ],
                if (client.address != null && client.address!.isNotEmpty) ...[
                  const Text('Alamat:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(client.address!),
                  const SizedBox(height: 8),
                ],
                if (client.notes != null && client.notes!.isNotEmpty) ...[
                  const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(client.notes!),
                  const SizedBox(height: 8),
                ],
                const Text('Ditambahkan pada:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${client.createdAt.day}/${client.createdAt.month}/${client.createdAt.year}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _showClientFormDialog(client: client);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari klien...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: _filterClients,
              )
            : const Text('Klien'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _filterClients('');
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredClients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _isSearching
                            ? 'Tidak ada klien yang cocok dengan pencarian'
                            : 'Belum ada klien terdaftar',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (!_isSearching)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Klien Baru'),
                          onPressed: () => _showClientFormDialog(),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = _filteredClients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: client.profilePictureUrl != null
                              ? NetworkImage(client.profilePictureUrl!) as ImageProvider
                              : null,
                          child: client.profilePictureUrl == null
                              ? Text(client.initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        title: Text(
                          client.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (client.companyName != null && client.companyName!.isNotEmpty)
                              Text(client.companyName!),
                            Text(client.email),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showClientFormDialog(client: client),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClient(client),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                        onTap: () => _showClientDetails(client),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientFormDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Tambah Klien',
      ),
    );
  }
} 