import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/partner_offer_controller.dart';
import '../../core/theme/app_colors.dart';

class PartnerOffersScreen extends StatefulWidget {
  const PartnerOffersScreen({super.key});

  @override
  State<PartnerOffersScreen> createState() => _PartnerOffersScreenState();
}

class _PartnerOffersScreenState extends State<PartnerOffersScreen> {
  final PartnerOfferController _offerController = Get.find<PartnerOfferController>();

  @override
  void initState() {
    super.initState();
    if (_offerController.offers.isEmpty) {
      _offerController.fetchPartnerOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Partner Offers'),
        backgroundColor: isDark ? null : const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _offerController.fetchPartnerOffers(refresh: true),
        child: Obx(() {
          if (_offerController.isLoading.value && _offerController.offers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_offerController.errorMessage.value.isNotEmpty &&
              _offerController.offers.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoCard(
                  text: _offerController.errorMessage.value,
                  isError: true,
                ),
              ],
            );
          }

          if (_offerController.offers.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _InfoCard(text: 'No partner offers available right now.'),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _offerController.offers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final offer = _offerController.offers[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBackgroundDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer.product?.name.isNotEmpty == true
                                ? offer.product!.name
                                : 'Offer',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${offer.points} pts',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Plan: ${offer.planType.toUpperCase()}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    if (offer.product != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Product Price: ₹${offer.product!.price}',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                    if (offer.note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        offer.note,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;
  final bool isError;

  const _InfoCard({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? AppColors.error.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? AppColors.error.withOpacity(0.4) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isError ? AppColors.error : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
