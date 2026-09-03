import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/services/api_service.dart';
import '../models/partner_offer_model.dart';

class PartnerOfferController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var offers = <PartnerOfferModel>[].obs;
  var errorMessage = ''.obs;

  Future<void> fetchPartnerOffers({bool refresh = false}) async {
    try {
      if (refresh) offers.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiService.get(AppConstants.partnerOffersEndpoint);
      final data = response.data;

      if (response.statusCode == 200 && data is Map && data['status'] == true) {
        final list = (data['data'] as List?) ?? const [];
        offers.value = list
            .whereType<Map>()
            .map(
              (item) => PartnerOfferModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } else {
        errorMessage.value =
            (data is Map ? data['message']?.toString() : null) ??
            'Could not load partner offers.';
      }
    } catch (e) {
      errorMessage.value = ApiService.toUserFriendlyError(
        e,
        fallback: 'Could not load partner offers.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
