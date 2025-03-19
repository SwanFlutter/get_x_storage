import 'package:example/theme_controller.dart';
import 'package:get_x_master/get_x_master.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
  }
}
