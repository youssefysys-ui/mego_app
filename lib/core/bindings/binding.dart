import 'package:get/get.dart';
import '../../features/auth/login/repo/login_repo.dart';
import '../../features/auth/login/repo/login_repo_impl.dart';
import '../../features/auth/verify_otp/verify_otp_controller.dart';

class MyBinding implements Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<LoginRepository>(() => LoginRepositoryImpl());

    // Controllers

    // Get.lazyPut<LoginController>(() => LoginController(Get.find<LoginRepository>()));
    //Get.lazyPut<RegisterController(() => LoginController(Get.find<LoginRepository>()));
    Get.lazyPut<VerifyOtpController>(() => VerifyOtpController());
    // Get.lazyPut<HomeController>(() => HomeController()); // Moved to HomeBinding
    // Get.lazyPut<SearchPlacesController>(() => SearchPlacesController()); // Moved to SearchPlacesBinding
  }
}
