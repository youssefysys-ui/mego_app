import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/shared_widgets/custom_appbar.dart';
import 'package:mego_app/features/search_places%20&%20calculation/widgets/confirm_button.dart';
import 'package:mego_app/features/search_places%20&%20calculation/widgets/search_results_widget.dart';
import 'controllers/search_places_controller.dart';
import 'widgets/search_input_section.dart';

class SearchPlacesView extends StatefulWidget {
  const SearchPlacesView({super.key});
  @override
  State<SearchPlacesView> createState() => _SearchPlacesViewState();
}

class _SearchPlacesViewState extends State<SearchPlacesView> {
  late SearchPlacesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SearchPlacesController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(height: 88, isBack: true),
      body: Column(
        children: [
          // Search Input Section
          SearchInputSection(controller: controller),
          
          SearchResultsWidget(controller: controller,),
         
        ],
      ),
      // Bottom Navigation Bar Style Confirm Button
      bottomNavigationBar:ConfirmButton(controller: controller,),
      
    );
  }

 

 
}