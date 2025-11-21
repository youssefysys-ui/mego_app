// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shop_app/core/res/colors.dart';
// import 'package:shop_app/core/validation/service_validators.dart';
// import 'package:shop_app/core/utils/app_message.dart';

// /// Reusable validation UI components
// class ValidationWidgets {
  
//   /// Display validation error as a styled container
//   static Widget errorContainer({
//     required ValidationResult result,
//     EdgeInsets? padding,
//     EdgeInsets? margin,
//   }) {
//     if (result.isValid) return const SizedBox.shrink();
    
//     return Container(
//       margin: margin ?? const EdgeInsets.only(top: 8),
//       padding: padding ?? const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: appErrorColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: appErrorColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 16,
//             color: appErrorColor,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               result.message ?? 'validation_error'.tr,
//               style:  TextStyle(
//                 fontFamily: 'fs_albert',
//                 fontSize: 12,
//                 color: appErrorColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Display validation error as a snackbar
//   static void showErrorSnackbar(ValidationResult result) {
//     if (result.isValid) return;
    
//     appMessageFail(
//       text: result.message ?? 'validation_error'.tr,
//       context: Get.context!,
//     );
//   }

//   /// Display validation error as a dialog
//   static void showErrorDialog({
//     required ValidationResult result,
//     String? titleKey,
//     VoidCallback? onOk,
//   }) {
//     if (result.isValid) return;
    
//     showDialog(
//       context: Get.context!,
//       builder: (context) => AlertDialog(
//         title: Text(
//           (titleKey ?? 'validation_error').tr,
//           style:  TextStyle(
//             fontFamily: 'fs_albert',
//             fontWeight: FontWeight.w400,
//             color: appErrorColor,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               result.message ?? 'unknown_validation_error'.tr,
//               style: TextStyle(
//                 fontFamily: 'fs_albert',
//                 fontSize: 14,
//               ),
//             ),
//             if (result.field != null) ...[
//               const SizedBox(height: 8),
//               Text(
//                 'field_field'.trParams({'field': result.field!.tr}),
//                 style:  TextStyle(
//                   fontFamily: 'fs_albert',
//                   fontSize: 12,
//                   color: txtColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//             if (result.details != null && result.details!.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               Text(
//                 'missing_fields'.tr,
//                 style:  TextStyle(
//                   fontFamily: 'fs_albert',
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: txtColor,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               ...result.details!.map((detail) => Padding(
//                 padding: const EdgeInsets.only(left: 8, top: 2),
//                 child: Text(
//                   '• ${detail.tr}',
//                   style:  TextStyle(
//                     fontFamily: 'fs_albert',
//                     fontSize: 12,
//                     color: txtColor,
//                   ),
//                 ),
//               )),
//             ],
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back();
//               onOk?.call();
//             },
//             child: Text(
//               'understood'.tr,
//               style:  TextStyle(
//                 fontFamily: 'fs_albert',
//                 color: primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Validation-aware form field wrapper
//   static Widget validatedFormField({
//     required Widget child,
//     ValidationResult? validationResult,
//     bool showErrorBelow = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         child,
//         if (showErrorBelow && validationResult != null && !validationResult.isValid)
//           errorContainer(result: validationResult),
//       ],
//     );
//   }

//   /// Validation-aware text field
//   static Widget validatedTextField({
//     required TextEditingController controller,
//     required String labelKey,
//     required String hintKey,
//     ValidationResult? validationResult,
//     Function(String)? onChanged,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     bool obscureText = false,
//     Widget? prefixIcon,
//     Widget? suffixIcon,
//     bool enabled = true,
//   }) {
//     final hasError = validationResult != null && !validationResult.isValid;
    
//     return validatedFormField(
//       validationResult: validationResult,
//       child: TextField(
//         controller: controller,
//         onChanged: onChanged,
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         obscureText: obscureText,
//         enabled: enabled,
//         decoration: InputDecoration(
//           labelText: labelKey.tr,
//           hintText: hintKey.tr,
//           prefixIcon: prefixIcon,
//           suffixIcon: suffixIcon,
//           filled: true,
//           fillColor: hasError 
//               ? appErrorColor.withOpacity(0.05)
//               : appSurfaceColor,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? appErrorColor : appDividerColor,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? appErrorColor : appDividerColor,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? appErrorColor : primaryColor,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide:  BorderSide(color: appErrorColor),
//           ),
//           labelStyle: TextStyle(
//             fontFamily: 'fs_albert',
//             color: hasError ? appErrorColor : txtColor,
//           ),
//           hintStyle: TextStyle(
//             fontFamily: 'fs_albert',
//             color: txtColor,
//           ),
//         ),
//         style: TextStyle(
//           fontFamily: 'fs_albert',
//           color: hasError ? appErrorColor : txtColor,
//         ),
//       ),
//     );
//   }

//   /// Validation-aware dropdown field
//   static Widget validatedDropdownField<T>({
//     required T? value,
//     required List<T> items,
//     required String labelKey,
//     required String hintKey,
//     required Function(T?) onChanged,
//     required String Function(T) itemToString,
//     ValidationResult? validationResult,
//     bool enabled = true,
//   }) {
//     final hasError = validationResult != null && !validationResult.isValid;
    
//     return validatedFormField(
//       validationResult: validationResult,
//       child: DropdownButtonFormField<T>(
//         value: value,
//         onChanged: enabled ? onChanged : null,
//         decoration: InputDecoration(
//           labelText: labelKey.tr,
//           hintText: hintKey.tr,
//           filled: true,
//           fillColor: hasError 
//               ? appErrorColor.withOpacity(0.05)
//               : appSurfaceColor,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? appErrorColor : appDividerColor,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? appErrorColor : appDividerColor,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(
//               color: hasError ? appErrorColor : primaryColor,
//             ),
//           ),
//           labelStyle: TextStyle(
//             fontFamily: 'fs_albert',
//             color: hasError ? appErrorColor : txtColor,
//           ),
//         ),
//         items: items.map((T item) {
//           return DropdownMenuItem<T>(
//             value: item,
//             child: Text(
//               itemToString(item),
//               style:  TextStyle(
//                 fontFamily: 'fs_albert',
//                 color: txtColor,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   /// Validation summary widget for multiple validation results
//   static Widget validationSummary({
//     required List<ValidationResult> results,
//     String? titleKey,
//     EdgeInsets? padding,
//   }) {
//     final errors = results.where((r) => !r.isValid).toList();
    
//     if (errors.isEmpty) return const SizedBox.shrink();
    
//     return Container(
//       padding: padding ?? const EdgeInsets.all(16),
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: appErrorColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: appErrorColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (titleKey != null) ...[
//             Row(
//               children: [
//                Icon(
//                   Icons.error_outline,
//                   color: appErrorColor,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   titleKey.tr,
//                   style: TextStyle(
//                     fontFamily: 'fs_albert',
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: appErrorColor,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//           ],
//           ...errors.map((error) => Padding(
//             padding: const EdgeInsets.only(bottom: 4),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                Text(
//                   '• ',
//                   style: TextStyle(
//                     color: appErrorColor,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     error.message ?? 'unknown_error'.tr,
//                     style:  TextStyle(
//                       fontFamily: 'fs_albert',
//                       fontSize: 14,
//                       color: appErrorColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     );
//   }

//   /// Success validation indicator
//   static Widget successIndicator({
//     String? messageKey,
//     EdgeInsets? padding,
//   }) {
//     return Container(
//       padding: padding ?? const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.green.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.check_circle_outline,
//             size: 16,
//             color: Colors.green,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               (messageKey ?? 'validation_passed').tr,
//               style: TextStyle(
//                 fontFamily: 'fs_albert',
//                 fontSize: 12,
//                 color: Colors.green,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Mixin for controllers to handle validation
// mixin ValidationMixin on GetxController {
  
//   /// Store validation results
//   final Map<String, ValidationResult> _validationResults = {};
  
//   /// Get validation result for a field
//   ValidationResult? getValidationResult(String field) {
//     return _validationResults[field];
//   }
  
//   /// Set validation result for a field
//   void setValidationResult(String field, ValidationResult result) {
//     _validationResults[field] = result;
//     update();
//   }
  
//   /// Clear validation result for a field
//   void clearValidationResult(String field) {
//     _validationResults.remove(field);
//     update();
//   }
  
//   /// Clear all validation results
//   void clearAllValidationResults() {
//     _validationResults.clear();
//     update();
//   }
  
//   /// Check if any validation errors exist
//   bool get hasValidationErrors {
//     return _validationResults.values.any((result) => !result.isValid);
//   }
  
//   /// Get all validation errors
//   List<ValidationResult> get validationErrors {
//     return _validationResults.values.where((result) => !result.isValid).toList();
//   }
  
//   /// Validate field and store result
//   ValidationResult validateAndStore(String field, ValidationResult result) {
//     setValidationResult(field, result);
//     return result;
//   }
  
//   /// Show validation error if exists
//   void showValidationErrorIfExists(String field) {
//     final result = getValidationResult(field);
//     if (result != null && !result.isValid) {
//       ValidationWidgets.showErrorSnackbar(result);
//     }
//   }
// }