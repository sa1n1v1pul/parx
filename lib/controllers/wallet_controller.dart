import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var wallet = Rxn<WalletModel>();
  var walletHistory = <WalletHistoryModel>[].obs;
  var currentPage = 1.obs;
  var hasMorePages = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchWallet() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('[WALLET_CONTROLLER] Fetching wallet...');
      print('[WALLET_CONTROLLER] Endpoint: ${AppConstants.walletEndpoint}');
      
      final response = await _apiService.get(AppConstants.walletEndpoint);

      print('[WALLET_CONTROLLER] Response status: ${response.statusCode}');
      print('[WALLET_CONTROLLER] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          print('[WALLET_CONTROLLER] Wallet data received: ${data['data']}');
          wallet.value = WalletModel.fromJson(data['data']);
          print('[WALLET_CONTROLLER] Wallet model created: ${wallet.value?.balance}');
        } else {
          print('[WALLET_CONTROLLER] API returned success: false');
          errorMessage.value = data['message'] ?? 'Failed to fetch wallet';
        }
      } else {
        print('[WALLET_CONTROLLER] Non-200 status code: ${response.statusCode}');
        errorMessage.value = 'Failed to fetch wallet. Status: ${response.statusCode}';
      }
      isLoading.value = false;
    } catch (e, stackTrace) {
      print('[WALLET_CONTROLLER] Error fetching wallet: $e');
      print('[WALLET_CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Error fetching wallet: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> fetchWalletHistory({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        walletHistory.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(
        AppConstants.walletHistoryEndpoint,
        queryParameters: {'page': currentPage.value},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final historyData = data['data']['data'] as List;
          walletHistory.addAll(
            historyData.map((item) => WalletHistoryModel.fromJson(item)),
          );
          
          hasMorePages.value = data['data']['next_page_url'] != null;
          if (hasMorePages.value) {
            currentPage.value++;
          }
        }
      }
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error fetching history: ${e.toString()}';
      isLoading.value = false;
    }
  }

  void refreshWallet() {
    fetchWallet();
    fetchWalletHistory(refresh: true);
  }
}

