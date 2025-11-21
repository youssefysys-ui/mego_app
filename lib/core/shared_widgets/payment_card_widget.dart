import 'package:flutter/material.dart';
import 'package:mego_app/core/shared_models/models.dart';
import '../res/app_colors.dart';

class PaymentCardWidget extends StatelessWidget {
  final RideModel rideModel;
  const PaymentCardWidget({super.key,required this.rideModel});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration:BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color:AppColors.backgroundColor
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Method: CASH',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.txtColor,
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              rideModel.totalPrice.toString().substring(0,4)+"€",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.txtColor,

                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
