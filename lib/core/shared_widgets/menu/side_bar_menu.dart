import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
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
    // Get user data from local storage
    final localStorage = GetIt.instance<LocalStorageService>();
    final userName = localStorage.userName ?? 'User';
    final userEmail = localStorage.userEmail ?? 'user@example.com';
    final userProfile = localStorage.userProfile;
    final userPhone = localStorage.read<String>('user_phone') ?? '';

    return Drawer(
      backgroundColor: AppColors.primaryColor,
      child: Column(
        children: [
          // Profile Section
          Stack(
            children: [
              SvgPicture.asset(AppImages.megoPatternImage),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                child: Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            child: Center(
              child: Container(
                height: 65,
                width: 220,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(AppImages.car),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(2.5),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: SvgPicture.asset(AppImages.food),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 44,),
        ],
      ),
    );
  }

  /// Handle logout process
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
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

    // If user confirmed logout
    if (shouldLogout == true) {
      try {
        // Show loading indicator

        LoadingWidget();


        // Sign out from Supabase
        await Supabase.instance.client.auth.signOut();
        print('✅ User signed out from Supabase');

        // Clear local storage data
        final localStorage = GetIt.instance<LocalStorageService>();
        await localStorage.deleteAuthToken();
        await localStorage.deleteUserEmail();
        await localStorage.deleteUserName();
        await localStorage.deleteUserModel();
        print('✅ Local storage cleared');

        // Close loading dialog
        Get.back();

        // Navigate to login screen and clear all previous routes
        Get.offAll(
          () => LoginView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
        // Show success message
        appMessageSuccess(text: 'Logged out successfully', context: context);



      } catch (e) {
        // Close loading dialog if open
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        print('❌ Error during logout: $e');
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