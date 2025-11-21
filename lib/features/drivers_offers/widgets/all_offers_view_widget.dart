import 'package:flutter/material.dart';
import 'package:mego_app/features/drivers_offers/driver_offer_model.dart';
import 'package:mego_app/features/drivers_offers/controllers/drivers_offers_controller.dart';
import 'package:mego_app/features/drivers_offers/widgets/offer_item_widget.dart';

import '../../../core/shared_models/user_ride_data.dart';

class AllOffersViewWidget extends StatelessWidget {
  final List<DriverOfferModel> offers;
  final DriversOffersController controller;
  final UserRideData userRideData;
  const AllOffersViewWidget({
    Key? key,
    required this.offers,
    required this.controller,
    required this.userRideData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return   
    Padding(
      padding: const EdgeInsets.only(top:88.0,left:32.0,right:32.0,bottom:12.0),
      child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: 6,
                        top: 4,
                      ),
                      itemCount: offers.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: OfferItemWidget(
                            offer: offer,
                            controller: controller,
                            userRideData:userRideData ,
                          ),
                        );
                      },
                    ),
    );
   
  }
}