import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide User;

class AuthRepository {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Singleton pattern
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  // Mendapatkan user yang sedang login
  User? get currentUser => _auth.currentUser;

  // Stream perubahan status autentikasi
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Login dengan email dan password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  // Registrasi user baru
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return response.user;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      // Sign out dari Google jika user sudah sign in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Sign out dari Supabase
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: null,  // Nilai null untuk aplikasi mobile
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  // Perbarui profil pengguna
  Future<void> updateUserProfile({String? name, String? photoUrl}) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (photoUrl != null) 'photo_url': photoUrl,
          },
        ),
      );
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  // Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Login dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. Dapatkan token autentikasi
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // 3. Login ke Supabase dengan token Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return response.user;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  // Mendapatkan nama user dari data user
  String? getUserName() {
    final userData = _auth.currentUser?.userMetadata;
    return userData?['name'] as String?;
  }

  // Mendapatkan email dari user yang sedang login
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Mendapatkan status login
  bool get isLoggedIn => currentUser != null;

  // Kirim email verifikasi
  Future<void> sendEmailVerification() async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: _supabase.auth.currentUser!.email!,
    );
  }

  // Memeriksa apakah email sudah diverifikasi
  bool get isEmailVerified {
    return currentUser?.emailConfirmedAt != null;
  }

  // Mendapatkan session
  Session? get session => _supabase.auth.currentSession;
} 