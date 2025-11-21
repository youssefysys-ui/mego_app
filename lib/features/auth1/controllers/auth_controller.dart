import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mego_app/core/shared_models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Reactive variables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  /// Check current authentication state
  void _checkAuthState() {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      currentUser.value = UserModel.fromJson(session!.user.toJson());
      isLoggedIn.value = true;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.session != null && response.user != null) {
        currentUser.value = UserModel.fromJson(response.user!.toJson());
        isLoggedIn.value = true;

        // Clear form
        _clearForm();

        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Navigate to home or dashboard
        Get.offAllNamed('/home'); // You'll need to create this route

      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Login Failed',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail() async {
    if (!registerFormKey.currentState!.validate()) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'display_name': nameController.text.trim(),
        },
      );

      if (response.session != null && response.user != null) {
        currentUser.value = UserModel.fromJson(response.user!.toJson());
        isLoggedIn.value = true;

        // Clear form
        _clearForm();

        // Show success message
        Get.snackbar(
          'Success',
          'Account created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Navigate to home or dashboard
        Get.offAllNamed('/home'); // You'll need to create this route

      } else if (response.user != null && response.session == null) {
        // Email confirmation required
        Get.snackbar(
          'Check Your Email',
          'Please check your email for verification link',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Registration Failed',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _supabase.auth.signOut();
      currentUser.value = null;
      isLoggedIn.value = false;

      // Clear form
      _clearForm();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to login
      Get.offAllNamed('/login');

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _supabase.auth.resetPasswordForEmail(email);

      Get.snackbar(
        'Check Your Email',
        'Password reset instructions sent to your email',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Reset Failed',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear form fields
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    errorMessage.value = '';
  }

  /// Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Password validator
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Confirm password validator
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Name validator
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}