import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/features/home/controller/home_controller.dart';
import 'package:mego_app/core/shared_widgets/menu/side_bar_menu.dart';
import '../../../core/shared_widgets/menu/drawer_menu_icon.dart';
import '../widgets/bottom_card_widget.dart';
import '../widgets/map_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller =Get.put(HomeController());
        //Get.find<HomeController>();
    controller.getLastUserDropOffLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(),
      drawer: const SideBarMenu(),
      body: Stack(
        children: [
          // Google Map
          MapWidget(controller: controller),
          // Drawer menu icon
          DrawerMenuIcon(),
          // Bottom Container with ride options and search
          GetBuilder<HomeController>(
            builder: (_) {
              if(controller.lastDropOffLocations.isNotEmpty) {
                return BottomCardWidget(lastUserDropOffLocation: controller.lastDropOffLocations,

                );
              }else{
                return const SizedBox();
              }

            }
          ),
        ],
      ),
    );
  }
}
