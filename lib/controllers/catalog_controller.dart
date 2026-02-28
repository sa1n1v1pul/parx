import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/catalog_model.dart';

class CatalogController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var catalogs = <CatalogModel>[].obs;
  var errorMessage = ''.obs;

  Future<void> fetchCatalogs({bool refresh = false}) async {
    try {
      if (refresh) catalogs.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(AppConstants.catalogsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true && data['data'] != null) {
          final list = data['data'] as List;
          catalogs.value =
              list.map((e) => CatalogModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error fetching catalogs: ${e.toString()}';
      isLoading.value = false;
    }
  }

  void refreshCatalogs() {
    fetchCatalogs(refresh: true);
  }
}
