import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_images.dart';
import '../../../features/history_trips/views/history_view.dart';
import '../../res/app_colors.dart';

class SideBarMenu extends StatelessWidget {
  const SideBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const CircleAvatar(
                      radius: 34,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kamilia Tomason',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kamilia@gmail.com',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: 'Roboto',
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
                  onTap: () {},
                  iconSize: 22,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildMenuItem(
                  icon: AppImages.aboutIcon,
                  title: 'About Us',
                  onTap: () {},
                  iconSize: 22,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildMenuItem(
                  icon:AppImages.settingsIcon,
                  title: 'Settings',
                  onTap: () {},
                  iconSize: 22,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildMenuItem(
                  icon: AppImages.couponsIcon,
                  title: 'Coupons',
                  onTap: () {},
                  iconSize: 22,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildMenuItem(
                  icon: AppImages.walletIcon,
                  title: 'Wallet',
                  onTap: () {},
                  iconSize: 22,
                ),
                const Divider(color: Colors.white24, height: 1),
                _buildMenuItem(
                  icon:AppImages.logoutIcon,
                  title: 'LogOut',
                  onTap: () {},
                  iconSize: 22,
                ),
              ],
            ),
          ),

          // Bottom Toggle Buttons
          Padding(
            padding:  EdgeInsets.all(16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child:Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(AppImages.car),
                      ),

                      // const Icon(
                      //   Icons.directions_car,
                      //   color: Colors.white,
                      //   size: 24,
                      // ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      child: SvgPicture.asset(AppImages.food)

                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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