// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shop_app/core/res/colors.dart';
// import 'package:shop_app/core/validation/service_validators.dart';
// import 'package:shop_app/core/validation/validation_widgets.dart';

// /// Example of how to use reusable validation components in a form
// class ValidatedLocationFormExample extends StatefulWidget {
//   const ValidatedLocationFormExample({super.key});

//   @override
//   State<ValidatedLocationFormExample> createState() => _ValidatedLocationFormExampleState();
// }

// class _ValidatedLocationFormExampleState extends State<ValidatedLocationFormExample> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Controllers
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _floorController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
  
//   // State
//   String? _selectedCity;
//   final List<String> _availableCities = ['Cairo', 'Alexandria', 'Giza'];
  
//   // Validation results
//   ValidationResult? _cityValidation;
//   ValidationResult? _addressValidation;
//   ValidationResult? _phoneValidation;
//   ValidationResult? _floorValidation;
//   ValidationResult? _landmarkValidation;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('validated_location_form_example'.tr),
//         backgroundColor: primaryColor,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title
//               Text(
//                 'location_information'.tr,
//                 style:  TextStyle(
//                   fontFamily: 'fs_albert',
//                   fontSize: 20,
//                   fontWeight: FontWeight.w400,
//                   color: txtColor,
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // City Dropdown with Validation
//               ValidationWidgets.validatedDropdownField<String>(
//                 value: _selectedCity,
//                 items: _availableCities,
//                 labelKey: 'city',
//                 hintKey: 'select_city',
//                 itemToString: (city) => city,
//                 validationResult: _cityValidation,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCity = value;
//                     _cityValidation = ServiceValidators.validateCity(value, _availableCities);
//                   });
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               // Address Field with Validation
//               ValidationWidgets.validatedTextField(
//                 controller: _addressController,
//                 labelKey: 'address',
//                 hintKey: 'enter_full_address',
//                 validationResult: _addressValidation,
//                 prefixIcon: const Icon(Icons.location_on_outlined),
//                 onChanged: (value) {
//                   setState(() {
//                     _addressValidation = ServiceValidators.validateAddress(value);
//                   });
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               // Phone Field with Validation
//               ValidationWidgets.validatedTextField(
//                 controller: _phoneController,
//                 labelKey: 'phone_number',
//                 hintKey: 'enter_phone_number',
//                 keyboardType: TextInputType.phone,
//                 validationResult: _phoneValidation,
//                 prefixIcon: const Icon(Icons.phone_outlined),
//                 onChanged: (value) {
//                   setState(() {
//                     _phoneValidation = ServiceValidators.validateUserContactInfo(null, "temp", value);
//                   });
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               // Floor Field with Validation (Optional)
//               ValidationWidgets.validatedTextField(
//                 controller: _floorController,
//                 labelKey: 'floor',
//                 hintKey: 'enter_floor_optional',
//                 validationResult: _floorValidation,
//                 prefixIcon: const Icon(Icons.layers_outlined),
//                 onChanged: (value) {
//                   // Optional field - only validate if not empty
//                   if (value.isNotEmpty) {
//                     setState(() {
//                       _floorValidation = ValidationHelpers.validateMinLength(value, 1, 'floor');
//                     });
//                   } else {
//                     setState(() {
//                       _floorValidation = null;
//                     });
//                   }
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               // Landmark Field with Validation (Optional)
//               ValidationWidgets.validatedTextField(
//                 controller: _landmarkController,
//                 labelKey: 'landmark',
//                 hintKey: 'enter_landmark_optional',
//                 validationResult: _landmarkValidation,
//                 prefixIcon: const Icon(Icons.place_outlined),
//                 onChanged: (value) {
//                   // Optional field with max length validation
//                   setState(() {
//                     _landmarkValidation = ValidationHelpers.validateMaxLength(value, 100, 'landmark');
//                   });
//                 },
//               ),
              
//               const SizedBox(height: 24),
              
//               // Validation Summary
//               ValidationWidgets.validationSummary(
//                 results: _getAllValidationResults(),
//                 titleKey: 'form_validation_errors',
//               ),
              
//               const SizedBox(height: 16),
              
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _validateAndSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'validate_and_submit'.tr,
//                     style: TextStyle(
//                       fontFamily: 'fs_albert',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 16),
              
//               // Example of showing success indicator
//               if (_isFormValid())
//                 ValidationWidgets.successIndicator(
//                   messageKey: 'form_validation_passed',
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<ValidationResult> _getAllValidationResults() {
//     return [
//       _cityValidation,
//       _addressValidation,
//       _phoneValidation,
//       _floorValidation,
//       _landmarkValidation,
//     ].where((result) => result != null && !result.isValid).cast<ValidationResult>().toList();
//   }

//   bool _isFormValid() {
//     return _cityValidation?.isValid == true &&
//            _addressValidation?.isValid == true &&
//            _phoneValidation?.isValid == true &&
//            (_floorValidation?.isValid != false) &&
//            (_landmarkValidation?.isValid != false);
//   }

//   void _validateAndSubmit() {
//     // Validate all fields at once using composite validation
//     final formValidation = ServiceValidators.validateLocationForm(
//       selectedCity: _selectedCity,
//       address: _addressController.text,
//       phone: _phoneController.text,
//       floor: _floorController.text,
//       landmark: _landmarkController.text,
//       availableCities: _availableCities,
//     );

//     if (formValidation.isValid) {
//       // Show success message
//       ValidationWidgets.successIndicator(messageKey: 'form_submitted_successfully');
      
//       // Process form data
//       _processFormData();
//     } else {
//       // Show error dialog
//       ValidationWidgets.showErrorDialog(
//         result: formValidation,
//         titleKey: 'form_validation_failed',
//         onOk: () {
//           // Focus on first invalid field
//           _focusFirstInvalidField();
//         },
//       );
//     }
//   }

//   void _focusFirstInvalidField() {
//     if (_cityValidation != null && !_cityValidation!.isValid) {
//       // Focus on city dropdown - could implement focus logic
//     } else if (_addressValidation != null && !_addressValidation!.isValid) {
//       _addressController.selection = TextSelection.fromPosition(
//         TextPosition(offset: _addressController.text.length),
//       );
//       FocusScope.of(context).requestFocus();
//     } else if (_phoneValidation != null && !_phoneValidation!.isValid) {
//       _phoneController.selection = TextSelection.fromPosition(
//         TextPosition(offset: _phoneController.text.length),
//       );
//       FocusScope.of(context).requestFocus();
//     }
//   }

//   void _processFormData() {
//     // Example of processing validated form data
//     final formData = {
//       'city': _selectedCity,
//       'address': _addressController.text,
//       'phone': _phoneController.text,
//       'floor': _floorController.text.isNotEmpty ? _floorController.text : null,
//       'landmark': _landmarkController.text.isNotEmpty ? _landmarkController.text : null,
//     };
    
//     print('Form data validated and ready for submission: $formData');
    
//     // Here you would typically save to database or send to API
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _phoneController.dispose();
//     _floorController.dispose();
//     _landmarkController.dispose();
//     super.dispose();
//   }
// }