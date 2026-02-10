import 'package:get/get.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var isLoading = false.obs;
  var products = <ProductModel>[].obs;
  var currentPage = 1.obs;
  var hasMorePages = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchProducts({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        products.clear();
      }

      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(
        AppConstants.productsEndpoint,
        queryParameters: {'page': currentPage.value},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final productsData = data['data']['data'] as List;
          products.addAll(
            productsData.map((item) => ProductModel.fromJson(item)),
          );
          
          hasMorePages.value = data['data']['next_page_url'] != null;
          if (hasMorePages.value) {
            currentPage.value++;
          }
        }
      }
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error fetching products: ${e.toString()}';
      isLoading.value = false;
    }
  }

  void refreshProducts() {
    fetchProducts(refresh: true);
  }
}

