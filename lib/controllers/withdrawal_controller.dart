import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/withdrawal_model.dart';

class WithdrawalController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var withdrawalRequests = <WithdrawalRequestModel>[].obs;
  var currentPage = 1.obs;
  var hasMorePages = true.obs;
  var errorMessage = ''.obs;

  Future<bool> submitWithdrawalRequest(double amount) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.post(
        AppConstants.withdrawalRequestEndpoint,
        data: {'amount': amount},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          isLoading.value = false;
          fetchWithdrawalRequests(refresh: true);
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Request failed';
          isLoading.value = false;
          return false;
        }
      } else {
        errorMessage.value = 'Request failed. Please try again.';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<void> fetchWithdrawalRequests({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        withdrawalRequests.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      print('[WITHDRAWAL_CONTROLLER] Fetching withdrawal history...');
      print('[WITHDRAWAL_CONTROLLER] Endpoint: ${AppConstants.withdrawalHistoryEndpoint}');
      print('[WITHDRAWAL_CONTROLLER] Page: ${currentPage.value}');

      final response = await _apiService.get(
        AppConstants.withdrawalHistoryEndpoint,
        queryParameters: {'page': currentPage.value},
      );

      print('[WITHDRAWAL_CONTROLLER] Response status: ${response.statusCode}');
      print('[WITHDRAWAL_CONTROLLER] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final historyData = data['data']['data'] as List;
          print('[WITHDRAWAL_CONTROLLER] Found ${historyData.length} withdrawal requests');
          
          withdrawalRequests.addAll(
            historyData.map((item) => WithdrawalRequestModel.fromJson(item)),
          );
          
          hasMorePages.value = data['data']['next_page_url'] != null;
          if (hasMorePages.value) {
            currentPage.value++;
          }
          
          print('[WITHDRAWAL_CONTROLLER] Total requests: ${withdrawalRequests.length}');
        } else {
          print('[WITHDRAWAL_CONTROLLER] API returned success: false');
          errorMessage.value = data['message'] ?? 'Failed to fetch withdrawal history';
        }
      } else {
        print('[WITHDRAWAL_CONTROLLER] Non-200 status: ${response.statusCode}');
        errorMessage.value = 'Failed to fetch withdrawal history';
      }
      
      isLoading.value = false;
    } catch (e, stackTrace) {
      print('[WITHDRAWAL_CONTROLLER] Error fetching requests: $e');
      print('[WITHDRAWAL_CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'Error fetching requests: ${e.toString()}';
      isLoading.value = false;
    }
  }
}

