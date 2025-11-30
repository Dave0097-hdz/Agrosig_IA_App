import 'package:get/get.dart';
import '../screens/auth/views/sign_in_screen.dart';

class SplaceController extends GetxController {
  static SplaceController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeSplash();
  }

  void _initializeSplash() async {
    try {
      // Tiempo suficiente para apreciar la animación (5 segundos)
      await Future.delayed(const Duration(seconds: 5));

      if (Get.isRegistered<SplaceController>()) {
        _navigateToSignIn();
      }
    } catch (e) {
      print('Error en splash: $e');
      _navigateToSignIn();
    }
  }

  void _navigateToSignIn() {
    Get.offAll(
          () => SignInScreen(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void onClose() {
    print('SplaceController disposed');
    super.onClose();
  }
}