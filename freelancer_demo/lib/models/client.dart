class Client {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? companyName;
  final String? address;
  final String? notes;
  final String? userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profilePictureUrl;

  Client({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.companyName,
    this.address,
    this.notes,
    this.userId,
    required this.createdAt,
    this.updatedAt,
    this.profilePictureUrl,
  });

  // Membuat salinan dengan beberapa data yang berubah
  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? companyName,
    String? address,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePictureUrl,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  // Mengonversi Client ke Map (untuk penyimpanan)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'company_name': companyName,
      'address': address,
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_picture_url': profilePictureUrl,
    };
  }

  // Membuat Client dari Map (untuk pembacaan dari penyimpanan)
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      companyName: map['company_name'],
      address: map['address'],
      notes: map['notes'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      profilePictureUrl: map['profile_picture_url'],
    );
  }

  // Mendapatkan inisial dari nama klien (untuk avatar)
  String get initials {
    if (name.isEmpty) return '';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  // Mendapatkan nama singkat (nama pertama saja)
  String get firstName {
    final nameParts = name.split(' ');
    return nameParts[0];
  }

  // Mendapatkan nama lengkap dengan perusahaan (jika ada)
  String get fullNameWithCompany {
    if (companyName != null && companyName!.isNotEmpty) {
      return '$name ($companyName)';
    }
    return name;
  }
} 