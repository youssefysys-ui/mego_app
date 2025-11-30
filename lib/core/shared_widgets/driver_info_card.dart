
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import '../res/app_colors.dart';

class DriverInfoCard extends StatelessWidget {
 final  DriverModel driverModel;
  const DriverInfoCard({super.key,required this.driverModel});

  @override
  Widget build(BuildContext context) {
    return   // Driver info card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Driver avatar
            Container(
              width: 55,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.buttonColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: driverModel.profileImage != null
                    ? Image.network(
                driverModel.profileImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.primaryColor,
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Driver details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                 driverModel.name ?? 'Driver',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.txtColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [

                      SvgPicture.asset(AppImages.star,),

                      const SizedBox(width: 4),
                      Text(
                        '${driverModel.rate ?? 4.9}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Car icon
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child:Column(
                  children: [
                    Image.network(
                   driverModel.carInfo!['image'] ??'',
                      height: 38,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.directions_car,
                        size: 28,
                        color: AppColors.txtColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          driverModel.carInfo!['brand'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.txtColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(" _ "),
                        Text(
                         driverModel.carInfo!['model'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.txtColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Text(
                         driverModel.carInfo!['plate_number']+" _ " ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.txtColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          driverModel.carInfo!['color'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.txtColor,
                            fontFamily: 'Roboto',
                          ),
                        ),

                      ],
                    ),
                    Row(
                      children: [
                        Text(
                        driverModel.carInfo!['year'].toString()?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.txtColor,
                            fontFamily: 'Roboto',
                          ),
                        ),

                      ],
                    )
                  ],
                )
            ),
          ],
        ),
      );
  }
}
