import 'package:get/get.dart';
// AuthController is already created in initial binding, so we just reference it

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController is already available from InitialBinding
    // We can add additional auth-related controllers here if needed
  }
}