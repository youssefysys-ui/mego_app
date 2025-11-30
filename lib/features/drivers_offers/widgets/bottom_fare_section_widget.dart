import 'package:flutter/material.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_models/user_ride_data.dart';

class BottomFareSectionWidget extends StatefulWidget {
  final UserRideData userRideData;
  
  const BottomFareSectionWidget({
    Key? key,
    required this.userRideData,
  }) : super(key: key);

  @override
  State<BottomFareSectionWidget> createState() => _BottomFareSectionWidgetState();
}

class _BottomFareSectionWidgetState extends State<BottomFareSectionWidget> {
  late double currentFare;

  @override
  void initState() {
    print("USER RIDE DATA=="+widget.userRideData.est_price.toString());
    print("USER RIDE DATA=="+widget.userRideData.originalPrice.toString());
    super.initState();
    currentFare = widget.userRideData.est_price;
  }

  void _increaseFare() {
    setState(() {
      currentFare += 1; // Increase by 5 euros
    });
  }

  void _decreaseFare() {
    setState(() {
     
        currentFare -= 1; // Decrease by 5 euros
      
    });
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      height: 230,
      decoration: const BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
    ),
    child:Column(children: [
      SizedBox(height: 4),
     
         Padding(
           padding: const EdgeInsets.only(left:130.0,right:130),
           child: Divider(thickness: 4,
                   color:Colors.grey[400]
                 ),
         ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left:28.0,right:28),
            child: Container(
              decoration:BoxDecoration(
                
                color: AppColors.backgroundColor,
               // Color(0xffF5EFE6),
                borderRadius: BorderRadius.circular(26),
              ),
              child:Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  //  SizedBox(width: 9,),
                  GestureDetector(
                    onTap: _decreaseFare,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.remove,color: Colors.black,),
                    ),
                  ),
                  Column(children: [
                SizedBox(height: 7),
                    Text("${currentFare.toStringAsFixed(0)}€",

                    style: TextStyle(
                        fontSize: 15,
                        fontFamily:'Roboto',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height:5),
                     Text("Recommended Fare: ${widget.userRideData.est_price.toStringAsFixed(0)}€",

                    style: TextStyle(
                        fontSize: 12,
                        fontFamily:'Roboto',
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                    ),
                     // SizedBox(height: 7),



                  ],),
                   GestureDetector(
                    onTap: _increaseFare,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.add,color: Colors.black,),
                    ),
                  ),
//                    SizedBox(width: 9,),

                ],),
              ),
            ),
          ),
           SizedBox(height: 10),
          Text('Finding your Ride',
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          )),
            SizedBox(height: 10),
            Image.asset(AppImages.loading,height: 40,width: 40,),
            
        


    ],),
    );
    // return Positioned(
    //   bottom: 0,
    //   left: 0,
    //   right: 0,
    //   child: Container(
      
    //     decoration: const BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.only(
    //         topLeft: Radius.circular(20),
    //         topRight: Radius.circular(20),
    //       ),
    //     ),
    //     child: SafeArea(
    //       child: Column(
    //        // mainAxisSize: MainAxisSize.min,
    //         children: [
    //           //_buildHandleBar(),
    //           const SizedBox(height: 12),
    //           _buildFareAdjustmentSection(),
    //           const SizedBox(height: 12),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }


}