


 import 'package:flutter/material.dart';

import '../res/app_images.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(child: Image.asset(AppImages.loading,
      height: 55,
    ));
  }
}
