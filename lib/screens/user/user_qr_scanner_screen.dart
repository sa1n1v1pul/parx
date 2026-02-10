import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/qr_scanner_overlay.dart';

class UserQrScannerScreen extends StatefulWidget {
  const UserQrScannerScreen({super.key});

  @override
  State<UserQrScannerScreen> createState() => _UserQrScannerScreenState();
}

class _UserQrScannerScreenState extends State<UserQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  bool _isQrDetected = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
        // Start camera after permission is granted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.start();
        });
      } else if (status.isDenied) {
        final result = await Permission.camera.request();
        setState(() {
          _hasPermission = result.isGranted;
          _isCheckingPermission = false;
        });
        
        if (_hasPermission) {
          // Start camera after permission is granted
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.start();
          });
        } else {
          Get.snackbar(
            'Camera Permission Required',
            'Please grant camera permission to scan QR codes',
            backgroundColor: AppColors.error,
            colorText: AppColors.textLight,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Get.back();
          });
        }
      } else {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
        Get.snackbar(
          'Camera Permission Denied',
          'Please enable camera permission from settings',
          backgroundColor: AppColors.error,
          colorText: AppColors.textLight,
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text('Open Settings'),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Get.back();
        });
      }
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
      Get.snackbar(
        'Error',
        'Failed to check camera permission: $e',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleQrCode(String qrCode) async {
    print('[USER_QR_SCANNER] QR code detected: $qrCode');
    
    if (_isProcessing) {
      print('[USER_QR_SCANNER] Already processing, ignoring');
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });

    // Stop camera while processing
    try {
      await _controller.stop();
      print('[USER_QR_SCANNER] Camera stopped for processing');
    } catch (e) {
      print('[USER_QR_SCANNER] Error stopping camera: $e');
    }

    try {
      print('[USER_QR_SCANNER] Parsing QR code: $qrCode');
      
      // Try to parse as URI
      Uri? uri = Uri.tryParse(qrCode);
      
      // If parsing fails, try adding https://
      if (uri == null || uri.scheme.isEmpty) {
        print('[USER_QR_SCANNER] No scheme found, trying to add https://');
        final urlWithScheme = qrCode.startsWith('http://') || qrCode.startsWith('https://') 
            ? qrCode 
            : 'https://$qrCode';
        uri = Uri.tryParse(urlWithScheme);
      }
      
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        print('[USER_QR_SCANNER] Valid URL found: $uri');
        
        // Try to launch URL with different modes
        try {
          // First try with external application mode
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          if (launched) {
            print('[USER_QR_SCANNER] URL launched successfully');
            // Close scanner after successful launch
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Get.back();
              }
            });
          } else {
            print('[USER_QR_SCANNER] launchUrl returned false, trying platformDefault');
            // Try with platform default mode
            await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Get.back();
              }
            });
          }
        } catch (launchError) {
          print('[USER_QR_SCANNER] Error launching URL: $launchError');
          _showError('Could not open the link: ${uri.toString()}');
        }
      } else {
        print('[USER_QR_SCANNER] Invalid URL format: $qrCode');
        // If not a URL, show as text
        _showMessage('QR Code Content: $qrCode');
      }
    } catch (e) {
      print('[USER_QR_SCANNER] Error processing QR code: $e');
      _showError('Error processing QR code: $e');
    } finally {
      // Restart camera after processing
      if (mounted) {
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          await _controller.start();
          print('[USER_QR_SCANNER] Camera restarted');
        } catch (e) {
          print('[USER_QR_SCANNER] Error restarting camera: $e');
        }
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _isQrDetected = false;
            });
          }
        });
      }
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showMessage(String message) {
    Get.snackbar(
      'QR Code Scanned',
      message,
      backgroundColor: AppColors.info,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Camera Permission Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please grant camera permission to scan QR codes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await openAppSettings();
                    if (result) {
                      await _checkCameraPermission();
                    }
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                setState(() {
                  _isQrDetected = true;
                });
                
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && !_isProcessing) {
                    _handleQrCode(barcode.rawValue!);
                    break;
                  }
                }
              } else {
                setState(() {
                  _isQrDetected = false;
                });
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Camera Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.errorDetails?.message ?? 'Failed to start camera',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _controller.start();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
          // QR Scanner Overlay with corner frame
          QrScannerOverlay(
            isScanning: !_isProcessing && !_isQrDetected,
            isDetected: _isQrDetected,
            scanArea: const Size(280, 280),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

