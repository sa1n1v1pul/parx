import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize API Service
  ApiService().init();
  
  // Initialize Auth Controller
  Get.put(AuthController());
  
  // Initialize Theme Controller
  Get.put(ThemeController());
  
  // Set system UI overlay style for full screen
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Obx(() => GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode.value,
      initialRoute: _getInitialRoute(),
      getPages: AppRoutes.getPages(),
      defaultTransition: Transition.cupertino,
    ));
  }

  String _getInitialRoute() {
    // Check if user is logged in
    if (StorageService.isLoggedIn()) {
      final userType = StorageService.getUserType();
      if (userType == 'dealer') {
        return AppRoutes.dealerHome;
      }
    }
    return AppRoutes.userTypeSelection;
  }
}
