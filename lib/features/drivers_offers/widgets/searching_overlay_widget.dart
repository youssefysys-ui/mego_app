import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/loading_widget.dart';

import '../../../core/res/app_colors.dart';

class SearchingOverlayWidget extends StatelessWidget {
  const SearchingOverlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:122.0,left: 33,right: 33,bottom: 30),
      child: Container(
        decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(12),
          color:AppColors.primaryColor.withOpacity(0.55)
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

           //   const LoadingWidget(),
              SvgPicture.asset(AppImages.search,
              height: 65,

              ),

              const SizedBox(height: 16),
              const Text(
                'Searching for drivers...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This may take a few moments',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}