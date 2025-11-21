import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_repo.dart';


class LoginRepositoryImpl implements LoginRepository {
  final SupabaseClient _supabase;
  
  LoginRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  @override
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      // Convert phone to email format for Supabase auth
      final email = '${phone.trim()}@mego.app';
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password.trim(),
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('An unexpected error occurred during login');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('An error occurred during sign out');
    }
  }

  @override
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  @override
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }
}
