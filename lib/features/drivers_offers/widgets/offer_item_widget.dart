import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_models/driver_model.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';
import 'package:mego_app/core/shared_widgets/loading_widget.dart';
import 'package:mego_app/features/drivers_offers/driver_offer_model.dart';
import 'package:mego_app/features/drivers_offers/controllers/drivers_offers_controller.dart';

class OfferItemWidget extends StatelessWidget {
  final DriverOfferModel offer;
  final DriversOffersController controller;
  final UserRideData userRideData;

  const OfferItemWidget({
    Key? key,
    required this.offer,
    required this.userRideData,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        //cardColor,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: offer.isActive ? AppColors.primaryColor.withOpacity(0.22):
              //.withValues(alpha: 0.3) :
          Colors.grey.shade200,
          width: offer.isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          _buildDriverInfoSection(),
          const SizedBox(height: 8),
          _buildActionButtons(),
        //  if (!offer.isExpired) _buildExpiryCountdown(),
        ],
      ),
    );
  }

  Widget _buildDriverInfoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Driver avatar with enhanced design
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.1),
                AppColors.primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              offer.displayProfileImage,
              fit: BoxFit.cover,
              width: 36,
              height: 36,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.primaryColor.withValues(alpha: 0.7),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Driver details with enhanced typography
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [

                  SvgPicture.asset(AppImages.star),

                  const SizedBox(width: 2),
                  Text(
                    '${offer.displayRating}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      offer.displayReviews,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                offer.displayCar,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Simplified price info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${offer.estimatedTime}m',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${offer.formattedPrice}€',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 36,
            child: ElevatedButton(
              onPressed: offer.isExpired ? null : () => controller.rejectOffer(offer),
              style: ElevatedButton.styleFrom(
                backgroundColor: offer.isExpired 
                    ? Colors.grey[300] 
                    : Colors.grey[100],
                foregroundColor: offer.isExpired 
                    ? Colors.grey[500] 
                    : Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: offer.isExpired 
                        ? Colors.grey[400]! 
                        : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                offer.isExpired ? 'Expired' : 'Decline',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            height: 36,
            child: ElevatedButton(
              onPressed: (controller.isAcceptingOffer || offer.isExpired) 
                  ? null 
                  : () => controller.acceptOffer(offer,userRideData,
                  
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: offer.isExpired 
                    ? Colors.grey[300] 
                    : AppColors.buttonColor,
                foregroundColor: offer.isExpired 
                    ? Colors.grey[700]
                    : AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: offer.isExpired ? 0 : 2,
                shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              child: controller.isAcceptingOffer
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                            decoration:BoxDecoration(
                              borderRadius:BorderRadius.circular(12),
                              color:  Colors.white
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LoadingWidget(),
                            )),
                        // SizedBox(
                        //   width: 18,
                        //   height: 18,
                        //   child: CircularProgressIndicator(
                        //     strokeWidth: 2,
                        //     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        //   ),
                        // ),
                        const SizedBox(width: 8),
                        Text(
                          'Accepting...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const SizedBox(width: 6),
                        Text(
                          offer.isExpired ? 'Expired' : 'Accept',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily:'Montserrat',

                            //letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryCountdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100.withValues(alpha: 0.3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            color: AppColors.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Expires in ${offer.formattedTimeUntilExpiry}',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}