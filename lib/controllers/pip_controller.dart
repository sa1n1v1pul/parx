import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../core/services/pip_service.dart';

class PipController extends GetxController {
  final isActive = false.obs;
  final isSystemPipActive = false.obs;
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  String? videoUrl;
  String? videoTitle;

  static void _onPipModeChanged(bool isInPipMode) {
    try {
      final c = Get.find<PipController>();
      c.isSystemPipActive.value = isInPipMode;
    } catch (_) {}
  }

  @override
  void onInit() {
    super.onInit();
    PipService.initialize(_onPipModeChanged);
  }

  void activatePip({
    required VideoPlayerController vc,
    required ChewieController cc,
    required String url,
    required String title,
  }) {
    videoController = vc;
    chewieController = cc;
    videoUrl = url;
    videoTitle = title;
    isActive.value = true;
  }

  void updateSystemPipStatus(bool value) {
    isSystemPipActive.value = value;
  }

  void deactivatePip() {
    isActive.value = false;
    isSystemPipActive.value = false;
    videoController = null;
    chewieController = null;
    videoUrl = null;
    videoTitle = null;
  }
}
