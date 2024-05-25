import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool isCurrent;
  final BaseCacheManager cacheManager;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.cacheManager,
    required this.isCurrent,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl ||
        widget.isCurrent != oldWidget.isCurrent) {
      _initializePlayer();
    } else if (widget.isCurrent && !_videoPlayerController.value.isPlaying) {
      _videoPlayerController.play();
    } else if (!widget.isCurrent && _videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
    }
  }

  void _initializePlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      looping: false,
      aspectRatio: 16 / 9,
      autoPlay: widget.isCurrent,
      allowMuting: true,
      placeholder: Center(
        child: CircularProgressIndicator(),
      ),
      allowPlaybackSpeedChanging: false,
    );

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position ==
              _videoPlayerController.value.duration &&
          _videoPlayerController.value.position != Duration.zero) {
        setState(() {
          _isVideoCompleted = true;
        });
        _chewieController.pause();
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chewie(controller: _chewieController),
        if (_chewieController.isPlaying && !_isVideoCompleted)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.pause,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
