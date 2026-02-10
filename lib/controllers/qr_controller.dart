import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import 'wallet_controller.dart';

class QrController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var scanResult = Rxn<Map<String, dynamic>>();

  Future<bool> scanQr(String qrToken) async {
    print('[QR_CONTROLLER] scanQr called with token: $qrToken');
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (qrToken.isEmpty || qrToken.trim().isEmpty) {
        print('[QR_CONTROLLER] Empty QR token provided');
        errorMessage.value = 'Invalid QR code';
        isLoading.value = false;
        return false;
      }

      print('[QR_CONTROLLER] Making API call to: ${AppConstants.scanQrEndpoint}');
      print('[QR_CONTROLLER] Request data: {qr_token: $qrToken}');

      final response = await _apiService.post(
        AppConstants.scanQrEndpoint,
        data: {'qr_token': qrToken},
      );

      print('[QR_CONTROLLER] API Response status: ${response.statusCode}');
      print('[QR_CONTROLLER] API Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          print('[QR_CONTROLLER] Scan successful');
          scanResult.value = data['data'];
          
          // Refresh wallet after successful scan
          try {
            final walletController = Get.find<WalletController>();
            await walletController.fetchWallet();
            print('[QR_CONTROLLER] Wallet refreshed successfully');
          } catch (e) {
            print('[QR_CONTROLLER] Error refreshing wallet: $e');
          }
          
          isLoading.value = false;
          return true;
        } else {
          final errorMsg = data['message'] ?? 'Scan failed';
          print('[QR_CONTROLLER] Scan failed: $errorMsg');
          errorMessage.value = errorMsg;
          isLoading.value = false;
          return false;
        }
      } else {
        print('[QR_CONTROLLER] API returned non-200 status: ${response.statusCode}');
        errorMessage.value = 'Scan failed. Please try again.';
        isLoading.value = false;
        return false;
      }
    } on DioException catch (e, stackTrace) {
      print('[QR_CONTROLLER] DioException occurred: $e');
      print('[QR_CONTROLLER] Status code: ${e.response?.statusCode}');
      print('[QR_CONTROLLER] Response data: ${e.response?.data}');
      print('[QR_CONTROLLER] Stack trace: $stackTrace');
      
      // Try to extract error message from response
      String userFriendlyMessage = 'Failed to scan QR code';
      
      if (e.response != null && e.response!.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          // Check for message in response
          if (responseData.containsKey('message')) {
            userFriendlyMessage = responseData['message'].toString();
          } else if (responseData.containsKey('error')) {
            userFriendlyMessage = responseData['error'].toString();
          }
        }
      }
      
      // If no message from response, use status code based messages
      if (userFriendlyMessage == 'Failed to scan QR code' || userFriendlyMessage.isEmpty) {
        final statusCode = e.response?.statusCode ?? 0;
        
        switch (statusCode) {
          case 400:
            userFriendlyMessage = 'This QR code is not valid for you or has already been used. Please scan a valid QR code.';
            break;
          case 404:
            userFriendlyMessage = 'QR code not found. Please scan a valid QR code.';
            break;
          case 403:
            userFriendlyMessage = 'You are not authorized to scan this QR code.';
            break;
          case 401:
            userFriendlyMessage = 'Session expired. Please login again.';
            break;
          default:
            if (e.type == DioExceptionType.connectionTimeout || 
                e.type == DioExceptionType.receiveTimeout) {
              userFriendlyMessage = 'Connection timeout. Please check your internet connection.';
            } else if (e.type == DioExceptionType.connectionError) {
              userFriendlyMessage = 'Network error. Please check your internet connection.';
            } else {
              userFriendlyMessage = 'This QR code is not valid or has already been used.';
            }
        }
      }
      
      // Make message more user-friendly
      if (userFriendlyMessage.toLowerCase().contains('already') || 
          userFriendlyMessage.toLowerCase().contains('used')) {
        userFriendlyMessage = 'This QR code has already been used. Please scan a new QR code.';
      } else if (userFriendlyMessage.toLowerCase().contains('invalid') || 
                 userFriendlyMessage.toLowerCase().contains('not valid')) {
        userFriendlyMessage = 'This QR code is not valid for you. Please scan a valid QR code.';
      }
      
      errorMessage.value = userFriendlyMessage;
      isLoading.value = false;
      return false;
    } catch (e, stackTrace) {
      print('[QR_CONTROLLER] Unexpected exception: $e');
      print('[QR_CONTROLLER] Stack trace: $stackTrace');
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      isLoading.value = false;
      return false;
    }
  }

  void clearResult() {
    scanResult.value = null;
    errorMessage.value = '';
  }
}
