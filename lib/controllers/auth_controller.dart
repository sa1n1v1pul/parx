import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/app_constants.dart';
import '../models/dealer_model.dart';
import 'wallet_controller.dart';
import 'product_controller.dart';
import 'profile_controller.dart';
import 'qr_controller.dart';
import 'withdrawal_controller.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var dealer = Rxn<DealerModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStoredDealer();
  }

  void loadStoredDealer() {
    final dealerData = StorageService.getDealerData();
    if (dealerData != null) {
      dealer.value = DealerModel.fromJson(dealerData);
    }
  }

  Future<bool> login(String login, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'login': login,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Save token
          await StorageService.saveToken(data['data']['token']);
          
          // Save dealer data
          final dealerData = data['data']['dealer'];
          await StorageService.saveDealerData(dealerData);
          dealer.value = DealerModel.fromJson(dealerData);
          
          // Save user type
          await StorageService.saveUserType('dealer');
          
          isLoading.value = false;
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Login failed';
          isLoading.value = false;
          return false;
        }
      } else {
        errorMessage.value = 'Login failed. Please try again.';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      isLoading.value = true;
      
      // Try to call logout API (but don't wait if it fails)
      try {
        await _apiService.post(AppConstants.logoutEndpoint);
      } catch (e) {
        // Continue with local logout even if API fails
      }
      
      // Step 1: Clear all storage data (GetStorage/SharedPreferences)
      await StorageService.clearAll();
      
      // Step 2: Clear all controller states
      dealer.value = null;
      errorMessage.value = '';
      
      // Step 3: Clear Dio cache and interceptors
      _apiService.clearCache();
      
      // Step 4: Reset all GetX controllers
      _clearAllControllers();
      
      // Step 5: Verify token is cleared
      final remainingToken = StorageService.getToken();
      if (remainingToken != null) {
        // Force remove again if still exists
        await StorageService.removeToken();
      }
      
      isLoading.value = false;
      return true;
    } catch (e) {
      // Ensure logout happens even if there's an error
      await StorageService.clearAll();
      dealer.value = null;
      errorMessage.value = '';
      _apiService.clearCache();
      _clearAllControllers();
      isLoading.value = false;
      return true;
    }
  }

  void _clearAllControllers() {
    try {
      // Clear wallet controller if exists
      if (Get.isRegistered<WalletController>()) {
        final walletController = Get.find<WalletController>();
        walletController.wallet.value = null;
        walletController.walletHistory.clear();
      }
      
      // Clear product controller if exists
      if (Get.isRegistered<ProductController>()) {
        final productController = Get.find<ProductController>();
        productController.products.clear();
      }
      
      // Clear profile controller if exists
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.dealer.value = null;
        profileController.selectedImage.value = null;
      }
      
      // Clear QR controller if exists
      if (Get.isRegistered<QrController>()) {
        final qrController = Get.find<QrController>();
        qrController.scanResult.value = null;
        qrController.clearResult();
      }
      
      // Clear withdrawal controller if exists
      if (Get.isRegistered<WithdrawalController>()) {
        final withdrawalController = Get.find<WithdrawalController>();
        withdrawalController.withdrawalRequests.clear();
      }
    } catch (e) {
      // Ignore errors in controller cleanup
    }
  }

  bool get isLoggedIn => StorageService.isLoggedIn();
}

