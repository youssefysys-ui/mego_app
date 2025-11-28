import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import '../../core/res/app_colors.dart';
import '../../core/res/app_images.dart';
import '../customer_support/customer_chat.dart';
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
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // Profile Section with enhanced design
                    _buildProfileSection(controller),

                    const SizedBox(height: 32),

                    // Account Information Card
                    _buildSectionHeader('Account Information', Icons.account_circle),
                    const SizedBox(height: 12),
                    _buildAccountInfoCard(controller, context),

                    const SizedBox(height: 32),

                    // Support & Help Section
                    _buildSectionHeader('Support & Help', Icons.help_outline),
                    const SizedBox(height: 12),
                    _buildSupportCard(controller, context),

                    const SizedBox(height: 32),

                    // App Information
                    _buildAppInfoSection(),

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

  Widget _buildProfileSection(SettingsController controller) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withOpacity(0.5),
              AppColors.primaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Picture with modern styling
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 37,
                      backgroundColor: AppColors.backgroundColor,
                      backgroundImage: controller.currentProfile.value.isNotEmpty
                          ? NetworkImage(controller.currentProfile.value)
                          : null,
                      child: controller.currentProfile.value.isEmpty
                          ? Text(
                        controller.currentName.value.isNotEmpty
                            ? controller.currentName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontFamily: 'Roboto',
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: AppColors.primaryColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Name
                  Text(
                    controller.currentName.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // User Phone with icon
                  if (controller.currentPhone.value.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            controller.currentPhone.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style:  TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.txtColor,
            fontFamily: 'Roboto',
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(SettingsController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name Edit Field
          Obx(() => _buildEditableField(
            controller: controller,
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            textController: controller.nameController,
            isEditing: controller.isEditingName.value,
            onEditToggle: controller.toggleEditName,
            onSave: () => controller.updateName(context),
            context: context,
            isFirst: true,
          )),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: Colors.grey.shade200,
              height: 1,
              thickness: 1,
            ),
          ),

          // Email Edit Field
          Obx(() => _buildEditableField(
            controller: controller,
            icon: Icons.email_outlined,
            label: 'Email Address',
            textController: controller.emailController,
            isEditing: controller.isEditingEmail.value,
            onEditToggle: controller.toggleEditEmail,
            onSave: () => controller.updateEmail(context),
            context: context,
            isFirst: false,
          )),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required SettingsController controller,
    required IconData icon,
    required String label,
    required TextEditingController textController,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required VoidCallback onSave,
    required BuildContext context,
    required bool isFirst,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEditDialog(
          context: context,
          controller: controller,
          icon: icon,
          label: label,
          textController: textController,
          onSave: onSave,
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: !isFirst ? const Radius.circular(20) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtColor.withOpacity(0.5),
                        fontFamily: 'Roboto',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      textController.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.txtColor,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Edit icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required SettingsController controller,
    required IconData icon,
    required String label,
    required TextEditingController textController,
    required VoidCallback onSave,
  }) {
    final tempController = TextEditingController(text: textController.text);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated background
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.15),
                      AppColors.primaryColor.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Edit $label',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.txtColor,
                  fontFamily: 'Roboto',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Update your ${label.toLowerCase()} information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.txtColor.withOpacity(0.6),
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 28),

              // Input Field with enhanced styling
              TextField(
                controller: tempController,
                autofocus: true,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.txtColor,
                  fontFamily: 'Roboto',
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: 'Enter your ${label.toLowerCase()}',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.primaryColor, size: 20),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2.5,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.txtColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.grey[400],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons with enhanced design
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                       // tempController.dispose();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.txtColor,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        textController.text = tempController.text;
                     //   tempController.dispose();
                        Navigator.of(context).pop();
                        onSave();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(SettingsController controller, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.infoColor.withOpacity(0.08),
            AppColors.infoColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.infoColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.infoColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(CustomerChatView());
          },

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.infoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    AppImages.customerSupportIcon,
                    width: 28,
                    height: 28,
                    color: AppColors.infoColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Support',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.txtColor,
                          fontFamily: 'Roboto',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chat with our support team',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.txtColor.withOpacity(0.6),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.infoColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              AppImages.logo,
              height: 50,
            ),
          ),
          const SizedBox(height: 16),

          Text("More than a ride, it's MEGo",
            style: TextStyle(color: AppColors.primaryColor,
              fontSize: 19,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          )
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