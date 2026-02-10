import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class QrScannerOverlay extends StatefulWidget {
  final bool isScanning;
  final bool isDetected;
  final Size scanArea;

  const QrScannerOverlay({
    super.key,
    required this.isScanning,
    required this.isDetected,
    this.scanArea = const Size(250, 250),
  });

  @override
  State<QrScannerOverlay> createState() => _QrScannerOverlayState();
}

class _QrScannerOverlayState extends State<QrScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanAreaSize = widget.scanArea;
    final left = (screenSize.width - scanAreaSize.width) / 2;
    final top = (screenSize.height - scanAreaSize.height) / 2 - 50;

    return Stack(
      children: [
        // Dark overlay with cutout
        CustomPaint(
          size: screenSize,
          painter: QrOverlayPainter(
            cutoutRect: Rect.fromLTWH(
              left,
              top,
              scanAreaSize.width,
              scanAreaSize.height,
            ),
          ),
        ),
        // Corner brackets
        Positioned(
          left: left,
          top: top,
          child: _CornerBrackets(
            size: scanAreaSize,
            color: widget.isDetected ? AppColors.accentGreen : AppColors.primaryBlue,
            animation: widget.isScanning ? _animation : null,
          ),
        ),
        // Scanning line animation
        if (widget.isScanning && !widget.isDetected)
          Positioned(
            left: left,
            top: top + (scanAreaSize.height * _animation.value),
            child: Container(
              width: scanAreaSize.width,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryBlue.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        // Instructions
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.isDetected
                    ? 'QR Code Detected!'
                    : 'Position QR code within the frame',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  final Size size;
  final Color color;
  final Animation<double>? animation;

  const _CornerBrackets({
    required this.size,
    required this.color,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final cornerLength = 30.0;
    final cornerWidth = 4.0;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Top Left
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(
              color: color,
              length: cornerLength,
              width: cornerWidth,
              isTopLeft: true,
            ),
          ),
          // Top Right
          Positioned(
            top: 0,
            right: 0,
            child: _Corner(
              color: color,
              length: cornerLength,
              width: cornerWidth,
              isTopLeft: false,
            ),
          ),
          // Bottom Left
          Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(
              color: color,
              length: cornerLength,
              width: cornerWidth,
              isTopLeft: true,
              isBottom: true,
            ),
          ),
          // Bottom Right
          Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(
              color: color,
              length: cornerLength,
              width: cornerWidth,
              isTopLeft: false,
              isBottom: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double length;
  final double width;
  final bool isTopLeft;
  final bool isBottom;

  const _Corner({
    required this.color,
    required this.length,
    required this.width,
    required this.isTopLeft,
    this.isBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          // Horizontal line
          Positioned(
            left: isTopLeft ? 0 : null,
            right: isTopLeft ? null : 0,
            top: isBottom ? null : 0,
            bottom: isBottom ? 0 : null,
            child: Container(
              width: length,
              height: width,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: isTopLeft && !isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                  topRight: !isTopLeft && !isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                  bottomLeft: isTopLeft && isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                  bottomRight: !isTopLeft && isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Vertical line
          Positioned(
            left: isTopLeft ? 0 : null,
            right: isTopLeft ? null : 0,
            top: isBottom ? null : 0,
            bottom: isBottom ? 0 : null,
            child: Container(
              width: width,
              height: length,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: isTopLeft && !isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                  topRight: !isTopLeft && !isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                  bottomLeft: isTopLeft && isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                  bottomRight: !isTopLeft && isBottom
                      ? const Radius.circular(2)
                      : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
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

class QrOverlayPainter extends CustomPainter {
  final Rect cutoutRect;

  QrOverlayPainter({required this.cutoutRect});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          cutoutRect,
          const Radius.circular(20),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(path, backgroundPaint);

    // Border around cutout
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cutoutRect,
        const Radius.circular(20),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

