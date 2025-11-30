import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mego_app/core/loading/loading.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/utils/app_message.dart';
import 'package:mego_app/features/settings/settings_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/about_us/about_us_view.dart';
import '../../../features/auth/login/views/login_view.dart';
import '../../../features/coupons/coupons_view.dart';
import '../../../features/customer_support/customer_chat.dart';
import '../../../features/history_trips/views/history_view.dart';
import '../../../features/wallet/wallet_view.dart';
import '../../local_db/local_db.dart';
import '../../res/app_colors.dart';

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = Storage.userName ?? 'User';
    final userEmail = Storage.userEmail ?? 'user@example.com';
    final userProfile = Storage.userProfile;
    final userPhone = Storage.userPhone ?? '';

    return Drawer(
      backgroundColor: AppColors.drawerColor,
      child: Container(
        decoration:BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,

              AppColors.drawerColor,


            ],
          ),
        ),
        child: Column(
          children: [
            // Profile Section
            Stack(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(AppImages.megoPatternImage,
                    width: 140,
                     // height: 200,
                     // fit:BoxFit.fitWidth,
                    ), SvgPicture.asset(AppImages.megoPatternImage,
                    width: 140,
                    //  height: 200,

                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 21,),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 33),
                          CircleAvatar(
                            radius: 34,
                            backgroundImage: userProfile != null && userProfile.isNotEmpty
                                ? NetworkImage(userProfile)
                                : null,
                            backgroundColor: Colors.white24,
                            child: userProfile == null || userProfile.isEmpty
                                ? Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          if (userPhone.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                userPhone,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: AppImages.historyIcon,
                    title: 'History',
                    onTap: () {
                      Get.to(HistoryView());
                    },
                    iconSize: 22,
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildMenuItem(
                    icon: AppImages.customerSupportIcon,
                    title: 'Customer Support',
                    onTap: () {
                      Get.to(CustomerChatView());
                    },
                    iconSize: 22,
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildMenuItem(
                    icon: AppImages.aboutIcon,
                    title: 'About Us',
                    onTap: () {
                      Get.to( AboutUsView());
                    },
                    iconSize: 22,
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildMenuItem(
                    icon: AppImages.settingsIcon,
                    title: 'Settings',
                    onTap: () {
                      Get.to( SettingsView());
                    },
                    iconSize: 22,
                  ),

                  const Divider(color: Colors.white24, height: 1),
                  _buildMenuItem(
                    icon: AppImages.couponsIcon,
                    title: 'Coupons',
                    onTap: () {
                      Get.to(CouponsView());
                    },
                    iconSize: 22,
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildMenuItem(
                    icon: AppImages.walletIcon,
                    title: 'Wallet',
                    onTap: () {
                      Get.to(WalletView());
                    },
                    iconSize: 22,
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildMenuItem(
                    icon:AppImages.logoutIcon,
                    title: 'LogOut',
                    onTap: () {
                      _handleLogout(context);
                    },
                    iconSize: 22,
                  ),
                ],
              ),
            ),

            // Bottom Toggle Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: Container(
                  height: 60,
                  width: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5C4),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B1C1C),
                            borderRadius: BorderRadius.circular(31),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                AppImages.car,
                                color: const Color(0xFFE8D5C4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(31),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                AppImages.food,
                                color: const Color(0xFF6B1C1C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // LOGOUT FROM FIREBASE & SUPABASE & CLEAR LOCAL DATA
  // ════════════════════════════════════════════════════════════════════════
  
  /// Handle complete logout process
  /// Signs out from Firebase, Supabase, and clears all local data
  Future<void> _handleLogout(BuildContext context) async {
    // PROCESS 1: Show confirmation dialog
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );

    // PROCESS 2: If user confirmed logout
    if (shouldLogout == true) {
      try {
        // Show loading indicator
        LoadingWidget();
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print("��� LOGOUT PROCESS: Starting complete logout");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        // PROCESS 3: Sign out from Firebase
        print('🔥 STEP 1: Signing out from Firebase');
        try {
          await FirebaseAuth.instance.signOut();
          print('✅ Firebase sign out successful');
        } catch (firebaseError) {
          print('⚠️ Warning: Firebase sign out failed: $firebaseError');
          // Continue with logout even if Firebase fails
        }

        // PROCESS 4: Sign out from Supabase
        print('🗄️ STEP 2: Signing out from Supabase');
        try {
          await Supabase.instance.client.auth.signOut();
          print('✅ Supabase sign out successful');
        } catch (supabaseError) {
          print('⚠️ Warning: Supabase sign out failed: $supabaseError');
          // Continue with logout even if Supabase fails
        }

        // PROCESS 5: Clear ALL local storage data
        print('💾 STEP 3: Clearing local storage data');
        await Storage.logout();
        print('✅ Local storage cleared completely');
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print("✅ LOGOUT COMPLETE: User logged out successfully");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

        // PROCESS 6: Close loading dialog
        Get.back();

        // PROCESS 7: Navigate to login screen and clear all routes
        Get.offAll(
          () => LoginView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        
        // PROCESS 8: Show success message
        appMessageSuccess(text: 'Logged out successfully', context: context);

      } catch (e) {
        // Close loading dialog if open
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        print('❌ ERROR: Logout process failed: $e');
        
        // Show error message
        appMessageFail(text: 'Failed to logout: ${e.toString()}', context: context);
      }
    }
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    double iconSize = 22,
  }) {
    return ListTile(
      leading: SvgPicture.asset(icon),

      // Icon(
      //   icon,
      //   color: Colors.white,
      //   size: iconSize,
      // ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    );
  }
}