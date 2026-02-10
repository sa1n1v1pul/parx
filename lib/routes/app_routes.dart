import 'package:get/get.dart';
import '../screens/user_type_selection_screen.dart';
import '../screens/dealer/dealer_login_screen.dart';
import '../screens/dealer/dealer_home_screen.dart';
import '../screens/user/user_qr_scanner_screen.dart';

class AppRoutes {
  static const String userTypeSelection = '/user-type-selection';
  static const String dealerLogin = '/dealer-login';
  static const String dealerHome = '/dealer-home';
  static const String userQrScanner = '/user-qr-scanner';

  static List<GetPage> getPages() {
    return [
      GetPage(
        name: userTypeSelection,
        page: () => const UserTypeSelectionScreen(),
      ),
      GetPage(
        name: dealerLogin,
        page: () => const DealerLoginScreen(),
      ),
      GetPage(
        name: dealerHome,
        page: () => const DealerHomeScreen(),
      ),
      GetPage(
        name: userQrScanner,
        page: () => const UserQrScannerScreen(),
      ),
    ];
  }
}

