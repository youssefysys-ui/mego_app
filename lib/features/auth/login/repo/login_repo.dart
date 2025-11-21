import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LoginRepository {
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  });
  
  Future<void> signOut();
  
  User? getCurrentUser();
  
  Session? getCurrentSession();
}
