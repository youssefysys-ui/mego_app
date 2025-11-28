


 import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../core/res/app_colors.dart';
import '../settings_controller.dart';

class AccountInfoCard extends StatelessWidget {
  final SettingsController controller;
   final   BuildContext context;
  const AccountInfoCard({super.key,required this.controller,required this.context});

  @override
  Widget build(BuildContext context) {
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
