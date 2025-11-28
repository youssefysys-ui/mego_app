import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/core/shared_widgets/loading_widget.dart';
import 'package:mego_app/features/settings/widgets/account_info_card.dart';
import 'package:mego_app/features/settings/widgets/app_info_section.dart';
import 'package:mego_app/features/settings/widgets/profile_section_widget.dart';
import 'package:mego_app/features/settings/widgets/section_header_widget.dart';
import 'package:mego_app/features/settings/widgets/support_card.dart';
import '../../core/res/app_colors.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar:CustomAppBar(height: 90,isBack: true),
      body: CustomScrollView(
        slivers: [

          SliverToLayoutBox(
            child: Obx(() {
              if (controller.isLoading.value) {

                return LoadingWidget();

              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // Profile Section with enhanced design

                    ProfileSectionWidget(controller:controller),

                    const SizedBox(height: 32),

                    SectionHeaderWidget(title:'Account Information',
                    icon: Icons.account_circle
                    ),

                    // Account Information Card

                    const SizedBox(height: 12),
                    AccountInfoCard(controller:controller, context: context,),


                    const SizedBox(height: 32),

                    SectionHeaderWidget(title:'Support & Help',
                        icon:  Icons.help_outline
                    ),

                    // Support & Help Section
                    const SizedBox(height: 12),
                    SupportCard(controller:controller, context: context,),
                    const SizedBox(height: 32),

                    // App Information
                    BuildAppInfoSection(),
                   // _buildAppInfoSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

}

// Extension to convert Sliver to Box
class SliverToLayoutBox extends SingleChildRenderObjectWidget {
  const SliverToLayoutBox({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverToBoxAdapter();
  }
}