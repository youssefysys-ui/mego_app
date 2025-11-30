import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/local_db/local_db.dart';
import '../../core/utils/app_message.dart';

class SettingsController extends GetxController {
  // Dependencies
  final SupabaseClient supabase = Supabase.instance.client;

  // Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isEditingName = false.obs;
  final RxBool isEditingEmail = false.obs;

  // User data - Make reactive for UI updates
  String userId = '';
  final RxString currentName = ''.obs;
  final RxString currentEmail = ''.obs;
  final RxString currentPhone = ''.obs;
  final RxString currentProfile = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  /// Load user data from local storage
  void _loadUserData() {


   // final userId= localStorage.userId;

    try {
      userId =Storage.userId.toString();

      currentName.value = Storage.userName.toString() ?? 'User';
      currentEmail.value = Storage.userEmail.toString() ?? '';
      currentPhone.value = Storage.userPhone.toString() ?? '';
      currentProfile.value =Storage.userProfile.toString() ?? '';

      nameController.text = currentName.value;
      emailController.text = currentEmail.value;

      print('📋 User data loaded:');
      print('   👤 Name: ${currentName.value}');
      print('   📧 Email: ${currentEmail.value}');
      print('   📱 Phone: ${currentPhone.value}');
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  /// Toggle edit mode for name
  void toggleEditName() {
    isEditingName.value = !isEditingName.value;
    if (!isEditingName.value) {
      nameController.text = currentName.value; // Reset if cancelled
    }
  }

  /// Toggle edit mode for email
  void toggleEditEmail() {
    isEditingEmail.value = !isEditingEmail.value;
    if (!isEditingEmail.value) {
      emailController.text = currentEmail.value; // Reset if cancelled
    }
  }

  /// Update user name
  Future<void> updateName(BuildContext context) async {
    if (nameController.text.trim().isEmpty) {
      appMessageFail(text: 'Name cannot be empty', context: context);
      return;
    }

    if (nameController.text.trim() == currentName.value) {
      isEditingName.value = false;
      return;
    }

    try {
      isLoading.value = true;
      print('\n💾 Updating user name...');

      final newName = nameController.text.trim();

      // Update in Supabase
      await supabase.from('users').update({
        'name': newName,
      }).eq('id', userId);

      print('✅ Name updated in Supabase');

      // Update local storage

      await Storage.save.userName(newName);
      currentName.value = newName;

      print('✅ Name updated in local storage');

      isEditingName.value = false;

      if (context.mounted) {
        appMessageSuccess(
          text: 'Name updated successfully!',
          context: context,
        );
      }
    } catch (e) {
      print('❌ Error updating name: $e');
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to update name: $e',
          context: context,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user email
  Future<void> updateEmail(BuildContext context) async {
    if (emailController.text.trim().isEmpty) {
      appMessageFail(text: 'Email cannot be empty', context: context);
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      appMessageFail(text: 'Please enter a valid email', context: context);
      return;
    }

    if (emailController.text.trim() == currentEmail.value) {
      isEditingEmail.value = false;
      return;
    }

    try {
      isLoading.value = true;
      print('\n💾 Updating user email...');

      final newEmail = emailController.text.trim();

      // Update in Supabase
      await supabase.from('users').update({
        'email': newEmail,
      }).eq('id', userId);

      print('✅ Email updated in Supabase');

      // Update local storage

      Storage.save.userEmail(newEmail);
      currentEmail.value = newEmail;

      print('✅ Email updated in local storage');

      isEditingEmail.value = false;

      if (context.mounted) {
        appMessageSuccess(
          text: 'Email updated successfully!',
          context: context,
        );
      }
    } catch (e) {
      print('❌ Error updating email: $e');
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to update email: $e',
          context: context,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Open customer support chat
  Future<void> openCustomerSupport(BuildContext context) async {
    try {
      print('💬 Opening customer support chat...');
      
      // Navigate to chat view with customer support
      // You can implement the chat screen navigation here
      appMessageSuccess(
        text: 'Opening customer support...',
        context: context,
      );

      // TODO: Navigate to chat screen
      // Get.to(() => ChatView(
      //   receiverId: 'customer_support_id',
      //   receiverName: 'Customer Support',
      // ));
      
    } catch (e) {
      print('❌ Error opening customer support: $e');
      if (context.mounted) {
        appMessageFail(
          text: 'Failed to open customer support',
          context: context,
        );
      }
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validators
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}
