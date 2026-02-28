import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/catalog_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/catalog_model.dart';
import 'catalog_detail_screen.dart';

class CatalogsViewAllScreen extends StatelessWidget {
  const CatalogsViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogController = Get.put(CatalogController());
    final themeController = Get.find<ThemeController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Catalogs'),
        backgroundColor: isDark ? null : const Color(0xFFF8FAFC),
        elevation: 0,
        actions: [
          Obx(() => IconButton(
                icon: Icon(themeController.themeIcon),
                onPressed: () => themeController.toggleTheme(),
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await catalogController.fetchCatalogs(refresh: true);
        },
        child: Obx(() {
          if (catalogController.isLoading.value &&
              catalogController.catalogs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (catalogController.catalogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No catalogs yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: catalogController.catalogs.length,
            itemBuilder: (context, index) {
              final catalog = catalogController.catalogs[index];
              return _CatalogCard(catalog: catalog);
            },
          );
        }),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  final CatalogModel catalog;

  const _CatalogCard({required this.catalog});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbUrl = catalog.image ?? (catalog.allImages.isNotEmpty ? catalog.allImages.first : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => CatalogDetailScreen(catalog: catalog)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: thumbUrl != null
                      ? Image.network(
                          thumbUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        )
                      : Icon(
                          Icons.collections_bookmark_outlined,
                          size: 48,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                catalog.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
