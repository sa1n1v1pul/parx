import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class InAppPipPlayer extends StatefulWidget {
  final VideoPlayerController videoController;
  final ChewieController chewieController;
  final String videoTitle;
  final VoidCallback onClose;
  final VoidCallback onExpand;

  const InAppPipPlayer({
    super.key,
    required this.videoController,
    required this.chewieController,
    required this.videoTitle,
    required this.onClose,
    required this.onExpand,
  });

  @override
  State<InAppPipPlayer> createState() => _InAppPipPlayerState();
}

class _InAppPipPlayerState extends State<InAppPipPlayer> {
  Offset _position = const Offset(16, 100);
  final double _pipWidth = 200.0;
  final double _pipHeight = 112.5;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            _position = Offset(
              (_position.dx + details.delta.dx).clamp(0.0, screenWidth - _pipWidth),
              (_position.dy + details.delta.dy).clamp(0.0, screenHeight - _pipHeight - 100),
            );
          });
        },
        child: Container(
          width: _pipWidth,
          height: _pipHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _pipWidth,
                  height: _pipHeight,
                  child: widget.videoController.value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: widget.videoController.value.size.width > 0
                                ? widget.videoController.value.size.width
                                : _pipWidth,
                            height: widget.videoController.value.size.height > 0
                                ? widget.videoController.value.size.height
                                : _pipHeight,
                            child: VideoPlayer(widget.videoController),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.videoTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: widget.onClose,
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: widget.onExpand,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.fullscreen, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
