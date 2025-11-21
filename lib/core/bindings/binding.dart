
import 'package:get/get.dart';

import 'package:mego_app/features/home/controller/home_controller.dart';

import '../../features/auth/login/controllers/login_controller.dart';
import '../../features/auth/login/repo/login_repo.dart';
import '../../features/auth/login/repo/login_repo_impl.dart';
import '../../features/auth/verify_otp/verify_otp_controller.dart';
import '../../features/auth1/controllers/auth_controller.dart';
import '../../features/search_places & calculation/controllers/search_places_controller.dart';


class MyBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<LoginRepository>(() => LoginRepositoryImpl());
    
    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<LoginController>(() => LoginController(Get.find<LoginRepository>()));
    Get.lazyPut<VerifyOtpController>(() => VerifyOtpController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SearchPlacesController>(() => SearchPlacesController(), fenix: true);
  }
}