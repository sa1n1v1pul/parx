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
        if (data is Map && data['success'] == true) {
          print('[QR_CONTROLLER] Scan successful');
          // API may return wallet_balance at root and/or nested under data
          scanResult.value = _normalizeScanSuccess(data);

          // Refresh wallet after successful scan (sync with server)
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
      
      final statusCode = e.response?.statusCode ?? 0;

      // If no message from response, use status code based messages
      if (userFriendlyMessage == 'Failed to scan QR code' || userFriendlyMessage.isEmpty) {
        switch (statusCode) {
          case 400:
            // Warranty not activated by customer yet (customer must scan first)
            userFriendlyMessage =
                'Warranty is not activated yet. Ask the customer to scan their product QR first to start the warranty. Then you can scan the same QR to claim your reward.';
            break;
          case 403:
            // QR exclusively assigned to another dealer/partner
            userFriendlyMessage =
                'This QR code is assigned to another partner. You cannot claim a reward on it.';
            break;
          case 404:
            userFriendlyMessage = 'QR code not found. Please scan a valid QR code.';
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
              userFriendlyMessage = 'Could not claim reward. Please try again.';
            }
        }
      }

      // Only soften generic messages; do not override clear 400/403 API text
      if (statusCode != 400 && statusCode != 403) {
        if (userFriendlyMessage.toLowerCase().contains('already') ||
            userFriendlyMessage.toLowerCase().contains('used')) {
          userFriendlyMessage = 'This QR code has already been used. Please scan a new QR code.';
        } else if (userFriendlyMessage.toLowerCase().contains('invalid') ||
            userFriendlyMessage.toLowerCase().contains('not valid')) {
          userFriendlyMessage = 'This QR code is not valid for you. Please scan a valid QR code.';
        }
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

  /// Builds one map for UI: nested `data` + root `wallet_balance` if API sends it there.
  Map<String, dynamic> _normalizeScanSuccess(Map<dynamic, dynamic> raw) {
    final out = <String, dynamic>{};
    final inner = raw['data'];
    if (inner is Map) {
      inner.forEach((k, v) {
        out[k.toString()] = v;
      });
    }
    if (raw['wallet_balance'] != null) {
      out['wallet_balance'] = raw['wallet_balance'];
    }
    return out;
  }
}
