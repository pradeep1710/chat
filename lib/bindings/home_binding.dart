import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/status_controller.dart';
import '../controllers/calls_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<StatusController>(() => StatusController());
    Get.lazyPut<CallsController>(() => CallsController());
  }
}