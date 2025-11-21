import 'package:get/get.dart';

class MyLocal implements Translations {
 
  
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'welcome': 'Welcome',
          'login': 'Login',
          'register': 'Register',
          // Add other key-value pairs for English
        },
        'ar': {
          'welcome': 'مرحبا',
          'login': 'تسجيل الدخول',
          'register': 'تسجيل',
          // Add other key-value pairs for Arabic
        },
  };
}