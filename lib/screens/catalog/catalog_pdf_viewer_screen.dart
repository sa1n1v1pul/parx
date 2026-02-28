import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class CatalogPdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const CatalogPdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<CatalogPdfViewerScreen> createState() => _CatalogPdfViewerScreenState();
}

class _CatalogPdfViewerScreenState extends State<CatalogPdfViewerScreen> {
  bool _isDownloading = false;
  static const _downloadChannel = MethodChannel('com.example.parx/download');

  Future<void> _downloadPdf() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final fileName = '${widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';

      if (Platform.isAndroid) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          if (mounted) setState(() => _isDownloading = false);
          return;
        }
      }

      final dio = Dio();
      final token = GetStorage().read(AppConstants.tokenKey) as String?;
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';

      await dio.download(
        widget.pdfUrl,
        tempPath,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          responseType: ResponseType.bytes,
        ),
      );

      if (!Platform.isAndroid) {
        if (mounted) {
          setState(() => _isDownloading = false);
          Get.snackbar('Downloaded', 'Saved to $tempPath', snackPosition: SnackPosition.BOTTOM);
        }
        return;
      }

      final result = await _downloadChannel.invokeMethod<Map<Object?, Object?>>(
        'saveToDownloads',
        <String, dynamic>{'sourcePath': tempPath, 'fileName': fileName},
      );

      try {
        File(tempPath).deleteSync();
      } catch (_) {}

      if (mounted) {
        setState(() => _isDownloading = false);
        if (result != null && result['success'] == true) {
          Get.snackbar(
            'Downloaded',
            'Saved to Downloads folder. Check File Manager or Recent.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Could not save to Downloads',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        Get.snackbar(
          'Error',
          'Download failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
        );
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Storage permission'),
          content: const Text(
            'To save PDF to Downloads folder, please allow storage permission. Open Settings?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      if (go == true) await openAppSettings();
      return false;
    }
    if (status.isDenied) {
      if (mounted) {
        final allow = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Allow storage?'),
            content: const Text(
              'This app needs storage permission to save the PDF to your Downloads folder. You will see the system permission dialog next.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Allow'),
              ),
            ],
          ),
        );
        if (allow != true) return false;
      }
      // This triggers the real Android system permission dialog (manifest must declare READ/WRITE_EXTERNAL_STORAGE)
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return false;
  }

  Map<String, String>? _headers() {
    final token = GetStorage().read(AppConstants.tokenKey) as String?;
    if (token == null) return null;
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadPdf,
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        headers: _headers(),
        onDocumentLoadFailed: (details) {
          Get.snackbar(
            'Error',
            details.description,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
          );
        },
      ),
    );
  }
}
