import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../core/constants/app_constants.dart';
import '../models/dealer_model.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();
  
  var isLoading = false.obs;
  var dealer = Rxn<DealerModel>();
  var errorMessage = ''.obs;
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(AppConstants.profileEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          dealer.value = DealerModel.fromJson(data['data']);
          await StorageService.saveDealerData(data['data']);
          
          // Update auth controller
          final authController = Get.find<AuthController>();
          authController.dealer.value = dealer.value;
        }
      }
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error fetching profile: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      errorMessage.value = 'Error picking image: ${e.toString()}';
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? username,
    String? address,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? upiId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final formData = <String, dynamic>{};
      if (name != null) formData['name'] = name;
      if (username != null) formData['username'] = username;
      if (address != null) formData['address'] = address;
      if (bankName != null) formData['bank_name'] = bankName;
      if (accountNumber != null) formData['account_number'] = accountNumber;
      if (ifscCode != null) formData['ifsc_code'] = ifscCode;
      if (upiId != null) formData['upi_id'] = upiId;

      final requestData = dio.FormData();
      
      // Add text fields
      formData.forEach((key, value) {
        requestData.fields.add(MapEntry(key, value.toString()));
      });
      
      // Add image if selected
      if (selectedImage.value != null) {
        requestData.files.add(
          MapEntry(
            'profile_pic',
            await dio.MultipartFile.fromFile(
              selectedImage.value!.path,
              filename: 'profile_pic.jpg',
            ),
          ),
        );
      }

      final response = await _apiService.postFormData(
        AppConstants.profileUpdateEndpoint,
        requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          dealer.value = DealerModel.fromJson(data['data']);
          await StorageService.saveDealerData(data['data']);
          
          // Update auth controller
          final authController = Get.find<AuthController>();
          authController.dealer.value = dealer.value;
          
          selectedImage.value = null;
          isLoading.value = false;
          return true;
        } else {
          errorMessage.value = data['message'] ?? 'Update failed';
          isLoading.value = false;
          return false;
        }
      } else {
        errorMessage.value = 'Update failed. Please try again.';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }
}

