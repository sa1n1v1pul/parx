import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PipService {
  static const MethodChannel _channel = MethodChannel('com.example.parx/pip');
  static Function(bool)? _onPipModeChanged;
  static bool _isInitialized = false;

  static void initialize(Function(bool isInPipMode) onPipModeChanged) {
    _onPipModeChanged = onPipModeChanged;
    if (!_isInitialized) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _isInitialized = true;
    }
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onPipModeChanged') {
      final isInPipMode = call.arguments as bool;
      _onPipModeChanged?.call(isInPipMode);
    }
  }

  static Future<bool> enterPipMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enterPipMode');
      return result ?? false;
    } catch (e) {
      debugPrint('Error entering PIP mode: $e');
      return false;
    }
  }

  static Future<void> setAutoPipEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setAutoPipEnabled', enabled);
    } catch (e) {
      debugPrint('Error setting auto PIP: $e');
    }
  }

  static Future<bool> exitPipMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('exitPipMode');
      return result ?? false;
    } catch (e) {
      debugPrint('Error exiting PIP mode: $e');
      return false;
    }
  }

  static Future<bool> isPipSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPipSupported');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isInPipMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('isInPipMode');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
