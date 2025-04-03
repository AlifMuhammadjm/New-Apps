import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer_os/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _supabase = SupabaseService().client;

  // Singleton pattern
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  // Register dengan email dan password
  Future<void> signUp(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  // Login dengan email dan password
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout gagal: ${e.toString()}');
    }
  }

  // Mendapatkan status autentikasi pengguna
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  // Mendapatkan data pengguna saat ini
  User? get currentUser => _supabase.auth.currentUser;

  // Mendapatkan ID pengguna saat ini
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Mendapatkan session pengguna saat ini
  Session? get currentSession => _supabase.auth.currentSession;
} 