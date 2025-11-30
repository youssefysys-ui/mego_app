import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mego_app/core/bindings/binding.dart';
import 'package:mego_app/core/language/local.dart';
import 'package:mego_app/core/language/local_controller.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/local_db/local_db.dart';
import 'features/splash/splash_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ovbnpmaltlpedueggtyr.supabase.co',
    anonKey: 'sb_publishable_mDuyLHyxQpNjGpeJj8CstQ_-XVp7GbO'
  );
  // Setup local storage
  await Storage.init();
  // Initialize FCM notifications
  // Get.put(FCMNotificationReceiver(), permanent: true);
  runApp(const MyApp());
  
  // Check for active rides after app starts (with delay to ensure UI is ready)
  // Future.delayed(const Duration(seconds: 2), () async {
  //   // Check for driver rides first
  //   final hasDriverRide = await RideRestorationService.checkAndRestoreActiveRide();
  //   print("🚗 Driver ride restoration status: $hasDriverRide");
  //   final hasPassengerRide = await PassengerRideRestorationService.checkAndRestoreActivePassengerRide();
  //   print("🚗 Driver ride restoration status: $hasPassengerRide");
  //   // If no driver ride found, check for passenger rides
  //   if (!hasDriverRide) {
  //
  //
  //     // If passenger ride is found, clear any driver ride restoration data
  //     if (!hasPassengerRide) {
  //       await RideRestorationService.clearDriverRideState();
  //     }
  //   } else {
  //     // If driver ride is found, clear any passenger ride data
  //     //await PassengerRideRestorationService.clearPassengerRideState();
  //   }
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Creates a premium text theme with professional typography
  TextTheme _buildPremiumTextTheme(BuildContext context) {
    return const TextTheme(
      // Display styles - for large text like headers
      displayLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),
      
      // Headline styles - for section headers
      headlineLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      ),
      // Title styles - for card titles and important text
      titleLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      
      // Body styles - for regular content
      bodyLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      
      // Label styles - for buttons and form labels
      labelLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(MyLocaleController());
    final box = GetStorage();
    // Always ensure English is set as default language
    box.writeIfNull('locale', 'en');
    String keylocal = box.read('locale') ?? 'en';
    Locale lang = Locale(keylocal);

    print('Selected locale: $keylocal');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: MyBinding(),
      locale: lang,
      translations: MyLocal(),
      title: 'MEGO',
      home: const SplashRouter(),
      //const LoginView(),
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ).copyWith(
          secondary: AppColors.primaryColor,
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        textTheme: _buildPremiumTextTheme(context),
        fontFamily: 'Montserrat',
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBarColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
            color: AppColors.whiteColor,
            height: 1.2,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.iconColor,
            size: 24,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.infoColor,
            size: 24,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: SplashColors.textColor,
            elevation: 2,
            shadowColor: AppColors.primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              height: 1.25,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SurfaceColors.containerColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: AppColors.lightTxtColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: SurfaceColors.dividerColor,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: SurfaceColors.dividerColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.failColor,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.failColor,
              width: 2,
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.backgroundColor,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.lightTxtColor,
          showUnselectedLabels: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: SplashColors.textColor,
        ),
      ),
      // Using initialRoute instead of home
    );
  }
}