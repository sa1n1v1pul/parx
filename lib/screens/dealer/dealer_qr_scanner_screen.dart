import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/qr_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/qr_scanner_overlay.dart';

class DealerQrScannerScreen extends StatefulWidget {
  const DealerQrScannerScreen({super.key});

  @override
  State<DealerQrScannerScreen> createState() => _DealerQrScannerScreenState();
}

class _DealerQrScannerScreenState extends State<DealerQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final QrController _qrController = Get.put(QrController());
  bool _isProcessing = false;
  bool _isQrDetected = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _cameraStarted = false;
  bool _hasCameraError = false;

  @override
  void initState() {
    super.initState();
    print('[QR_SCANNER] initState called');
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    print('[QR_SCANNER] Checking camera permission...');
    try {
      final status = await Permission.camera.status;
      print('[QR_SCANNER] Camera permission status: $status');
      
      if (status.isGranted) {
        print('[QR_SCANNER] Camera permission already granted');
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
        // Start camera after permission is granted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('[QR_SCANNER] Starting camera after permission granted');
          _startCamera();
        });
      } else if (status.isDenied) {
        print('[QR_SCANNER] Camera permission denied, requesting...');
        final result = await Permission.camera.request();
        print('[QR_SCANNER] Permission request result: $result');
        setState(() {
          _hasPermission = result.isGranted;
          _isCheckingPermission = false;
        });
        
        if (_hasPermission) {
          print('[QR_SCANNER] Camera permission granted after request');
          // Start camera after permission is granted
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('[QR_SCANNER] Starting camera after permission request');
            _startCamera();
          });
        } else {
          print('[QR_SCANNER] Camera permission denied after request');
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
        print('[QR_SCANNER] Camera permission permanently denied');
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
    } catch (e, stackTrace) {
      print('[QR_SCANNER] Error checking camera permission: $e');
      print('[QR_SCANNER] Stack trace: $stackTrace');
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

  Future<void> _startCamera() async {
    // Don't start if already started
    if (_cameraStarted) {
      print('[QR_SCANNER] Camera already started, skipping...');
      return;
    }
    
    try {
      print('[QR_SCANNER] Attempting to start camera...');
      await _controller.start();
      print('[QR_SCANNER] Camera started successfully');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _cameraStarted = true;
              _hasCameraError = false;
            });
          }
        });
      }
    } catch (e, stackTrace) {
      print('[QR_SCANNER] Error starting camera: $e');
      print('[QR_SCANNER] Stack trace: $stackTrace');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasCameraError = true;
              _cameraStarted = false;
            });
            Get.snackbar(
              'Camera Error',
              'Failed to start camera: $e',
              backgroundColor: AppColors.error,
              colorText: AppColors.textLight,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    print('[QR_SCANNER] Disposing scanner...');
    _controller.dispose();
    super.dispose();
  }

  String _extractQrToken(String qrValue) {
    // Check if it's a URL format
    if (qrValue.contains('qr/')) {
      // Extract token from URL: https://.../qr/UUID or /qr/UUID
      final uri = Uri.tryParse(qrValue);
      if (uri != null) {
        final pathSegments = uri.pathSegments;
        final qrIndex = pathSegments.indexOf('qr');
        if (qrIndex != -1 && qrIndex < pathSegments.length - 1) {
          final token = pathSegments[qrIndex + 1];
          print('[QR_SCANNER] Extracted token from URL: $token');
          return token;
        }
      }
      // Fallback: try to extract UUID pattern from URL
      final uuidPattern = RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', caseSensitive: false);
      final match = uuidPattern.firstMatch(qrValue);
      if (match != null) {
        final token = match.group(0)!;
        print('[QR_SCANNER] Extracted UUID token from URL: $token');
        return token;
      }
    }
    // If not a URL, return as is (assuming it's already a token)
    print('[QR_SCANNER] Using QR value as token: $qrValue');
    return qrValue;
  }

  Future<void> _handleQrCode(String qrValue) async {
    print('[QR_SCANNER] QR code detected: $qrValue');
    
    if (_isProcessing) {
      print('[QR_SCANNER] Already processing, ignoring QR code');
      return;
    }
    
    if (qrValue.isEmpty || qrValue.trim().isEmpty) {
      print('[QR_SCANNER] Empty QR value, ignoring');
      return;
    }
    
    // Extract token from URL if needed
    final qrToken = _extractQrToken(qrValue);
    
    if (qrToken.isEmpty) {
      print('[QR_SCANNER] Failed to extract token from QR value');
      Get.snackbar(
        'Invalid QR Code',
        'Could not extract token from QR code',
        backgroundColor: AppColors.error,
        colorText: AppColors.textLight,
      );
      return;
    }
    
    print('[QR_SCANNER] Processing QR code with token: $qrToken');
    setState(() {
      _isProcessing = true;
    });

    // Stop camera while processing to prevent multiple scans
    try {
      await _controller.stop();
      print('[QR_SCANNER] Camera stopped for processing');
    } catch (e) {
      print('[QR_SCANNER] Error stopping camera: $e');
    }

    final success = await _qrController.scanQr(qrToken);

    // Restart camera after processing
    if (mounted) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        // Only restart if not already started
        if (!_cameraStarted) {
          await _controller.start();
          print('[QR_SCANNER] Camera restarted after processing');
        } else {
          print('[QR_SCANNER] Camera already running, skipping restart');
        }
      } catch (e) {
        print('[QR_SCANNER] Error restarting camera: $e');
        // If error is "already started", update flag
        if (e.toString().contains('already started')) {
          if (mounted) {
            setState(() {
              _cameraStarted = true;
            });
          }
        }
      }
    }

    if (success) {
      print('[QR_SCANNER] QR scan successful');
      final data = _qrController.scanResult.value;
      Get.dialog(
        AlertDialog(
          title: const Text('Success!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${data?['product']?['name'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Reward Points: ${data?['product']?['reward_points'] ?? 0}'),
              const SizedBox(height: 8),
              Text('New Balance: ${data?['wallet_balance'] ?? '0.00'} Points'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final errorMsg = _qrController.errorMessage.value.isNotEmpty 
          ? _qrController.errorMessage.value 
          : 'Failed to scan QR code';
      print('[QR_SCANNER] QR scan failed: $errorMsg');
      
      // Show user-friendly error dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Scan Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            errorMsg,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Close scanner screen and go back to home
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false, // Prevent dismissing by tapping outside
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isQrDetected = false;
        });
        _qrController.clearResult();
        print('[QR_SCANNER] Processing completed, ready for next scan');
      }
    });
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
          SizedBox.expand(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                print('[QR_SCANNER] onDetect called, barcodes found: ${barcodes.length}');
                
                if (barcodes.isNotEmpty) {
                  setState(() {
                    _isQrDetected = true;
                  });
                  
                  for (final barcode in barcodes) {
                    print('[QR_SCANNER] Barcode type: ${barcode.type}, value: ${barcode.rawValue}');
                    if (barcode.rawValue != null && !_isProcessing) {
                      print('[QR_SCANNER] Valid barcode found, processing...');
                      _handleQrCode(barcode.rawValue!);
                      break;
                    } else {
                      print('[QR_SCANNER] Barcode skipped: rawValue=${barcode.rawValue}, isProcessing=$_isProcessing');
                    }
                  }
                } else {
                  if (_isQrDetected) {
                    setState(() {
                      _isQrDetected = false;
                    });
                  }
                }
              },
              errorBuilder: (context, error, child) {
                final errorMessage = error.errorDetails?.message ?? '';
                print('[QR_SCANNER] errorBuilder called: $errorMessage');
                
                // Ignore "already started" error - camera is working fine
                if (errorMessage.contains('already started')) {
                  print('[QR_SCANNER] Ignoring "already started" error - camera is working');
                  // Return the child (camera view) if available, or null
                  return child ?? const SizedBox.shrink();
                }
                
                // Update state after build phase for real errors only
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _hasCameraError = true;
                      _cameraStarted = false;
                    });
                  }
                });
                
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
                        errorMessage,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          await _startCamera();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Show loading while camera is starting
          if (!_cameraStarted && !_hasCameraError && _hasPermission)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Starting camera...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          // QR Scanner Overlay with corner frame
          QrScannerOverlay(
            isScanning: !_isProcessing && !_isQrDetected,
            isDetected: _isQrDetected,
            scanArea: const Size(280, 280),
          ),
          if (_isProcessing || _qrController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

