import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/catalog_model.dart';
import 'catalog_pdf_viewer_screen.dart';
import 'catalog_gallery_full_screen.dart';
import 'catalog_video_screen.dart';

class CatalogDetailScreen extends StatelessWidget {
  final CatalogModel catalog;

  const CatalogDetailScreen({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPdf = catalog.pdf != null && catalog.pdf!.isNotEmpty;
    final hasVideo = catalog.video != null && catalog.video!.isNotEmpty;
    final images = catalog.allImages;
    final hasGallery = images.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(catalog.title),
        backgroundColor: isDark ? null : const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (catalog.image != null && catalog.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    catalog.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                      child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            if (hasPdf) ...[
              _SectionCard(
                icon: Icons.picture_as_pdf,
                title: 'PDF',
                subtitle: 'View or download',
                onTap: () => Get.to(() => CatalogPdfViewerScreen(
                      pdfUrl: catalog.pdf!,
                      title: catalog.title,
                    )),
              ),
              const SizedBox(height: 12),
            ],

            if (hasVideo) ...[
              _SectionCard(
                icon: Icons.video_library,
                title: 'Video',
                subtitle: 'Watch video',
                onTap: () => Get.to(() => CatalogVideoScreen(
                      videoUrl: catalog.video!,
                      title: catalog.title,
                    )),
              ),
              const SizedBox(height: 12),
            ],

            if (hasGallery) ...[
              Text(
                'Gallery',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => Get.to(() => CatalogGalleryFullScreen(
                              imageUrls: images,
                              initialIndex: index,
                              title: catalog.title,
                            )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 100,
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Get.to(() => CatalogGalleryFullScreen(
                      imageUrls: images,
                      initialIndex: 0,
                      title: catalog.title,
                    )),
                icon: const Icon(Icons.fullscreen),
                label: const Text('View full screen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.cardBackgroundDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackgroundDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}
