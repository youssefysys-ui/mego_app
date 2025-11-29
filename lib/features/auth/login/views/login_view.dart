import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mego_app/core/res/app_colors.dart';
import 'package:mego_app/core/res/app_images.dart';
import 'package:mego_app/core/shared_widgets/Custom_button.dart';
import 'package:mego_app/core/shared_widgets/custom_textformfield.dart';
import 'package:mego_app/core/shared_widgets/social_button.dart';
import 'package:mego_app/features/auth/register/register_view.dart';
import '../controllers/login_controller.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  LoginController ?controller ;

  @override
  void initState() {
    controller = Get.put(LoginController());
    super.initState();
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Image.asset(AppImages.blurLogo, height: 100),
                    SizedBox(height: 12),
                    Center(
                      child: Text("More than a ride, it's MEGo",
                        style:TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left:38.0,right:38),
                      child: CustomTextFormField(hint: 'Enter Your Phone Number'.tr,
                        prefixIcon:AppImages.phone,
                        type: TextInputType.phone,
                        controller: controller!.phoneController),
                    ),
                    SizedBox(height: 20),

                    Obx(() => CustomButton(
                      text: controller!.isLoading.value ? 'Signing in...' : 'Sign in',
                      onPressed: () {
                        if (!controller!.isLoading.value) {
                          controller!.login(context);
                        }
                      },
                    )),

                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left:44.0,right:44),
                      child: Divider(
                        color: Colors.grey[500],
                        thickness: 1,
                      ),
                    ),
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(left:48.0,right:48),
                      child: SocialButton(
                        text: 'Continue with Google',
                        iconPath: AppImages.google,
                        onPressed: () {
                          controller!.googleLogin(context);
                        },
                      ),
                    ),

                    SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.only(left:48.0,right:48),
                      child: SocialButton(
                        text: 'Continue with Apple',
                        iconPath: AppImages.apple,
                        onPressed: () {},
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          //bottom design - always at bottom of screen
          Stack(
            children: [
              SvgPicture.asset(AppImages.loginVector),
              Positioned(
                bottom: 39,
                left: 10,
                right: 10,
                child: InkWell(
                  onTap:(){
                    Get.to(() => RegisterView(),
                      transition: Transition.leftToRightWithFade,
                      duration: const Duration(milliseconds: 900),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?".tr,
                        style: TextStyle(
                          color: AppColors.lightTxtColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Sign up".tr,
                        style: TextStyle(
                          color: AppColors.lightTxtColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}