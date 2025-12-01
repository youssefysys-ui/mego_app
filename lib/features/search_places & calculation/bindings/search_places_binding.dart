import 'package:get/get.dart';
import '../controllers/est_services_controller.dart';
import '../controllers/search_places_controller.dart';

class SearchPlacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EstServicesController>(() => EstServicesController());
    Get.lazyPut<SearchPlacesController>(() => SearchPlacesController());
  }
}
