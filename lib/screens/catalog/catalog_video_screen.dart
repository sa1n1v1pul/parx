import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CatalogVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const CatalogVideoScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<CatalogVideoScreen> createState() => _CatalogVideoScreenState();
}

class _CatalogVideoScreenState extends State<CatalogVideoScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoController.initialize();
    if (mounted) {
      _setupChewie();
      setState(() => _isInitialized = true);
    }
  }

  void _setupChewie() {
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoController.value.aspectRatio,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightBlue,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }

  void _close() {
    _videoController.pause();
    Get.back();
  }

  @override
  void dispose() {
    _videoController.pause();
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _close,
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _close,
          ),
        ],
      ),
      body: _isInitialized && _chewieController != null
          ? Center(child: Chewie(controller: _chewieController!))
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
