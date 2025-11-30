


 import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../res/app_colors.dart';
import '../../res/app_images.dart';

class DrawerMenuIcon extends StatelessWidget {
   const DrawerMenuIcon({super.key});

   @override
   Widget build(BuildContext context) {
     return  Positioned(
       top: 20,
       left: 20,
       child: Container(
         width: 50,
         height: 50,
         decoration: BoxDecoration(
           color: AppColors.primaryColor,
           borderRadius: BorderRadius.circular(25),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 8,
               offset: const Offset(0, 2),
             ),
           ],
         ),
         child: Material(
           color: Colors.transparent,
           child: InkWell(
             borderRadius: BorderRadius.circular(25),
             onTap: () {
               Scaffold.of(context).openDrawer();
             },
             child: Center(
               child: SvgPicture.asset(
                 AppImages.drIcon,
                //  width: 61,
                width:18
               ),
             ),
           ),
         ),
       ),
     );
   }
 }
