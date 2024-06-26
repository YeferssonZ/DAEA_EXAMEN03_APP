// VideoPlayerWidget.dart
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String userId;
  final String videoId;
  final bool isCurrent;
  final BaseCacheManager cacheManager;
  final ValueChanged<double> onTimeWatched;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.userId,
    required this.videoId,
    required this.cacheManager,
    required this.isCurrent,
    required this.onTimeWatched,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late Ticker _ticker;
  Duration _totalWatchedDuration = Duration.zero;
  Duration _lastReportedPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _ticker = createTicker((elapsed) => _updateTimeWatched(elapsed))..start();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl ||
        widget.isCurrent != oldWidget.isCurrent) {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      }
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
      if (_videoPlayerController.value.isInitialized) {
        if (_videoPlayerController.value.position ==
                _videoPlayerController.value.duration &&
            _videoPlayerController.value.position != Duration.zero) {
          _sendRating();
        }
      }
    });
  }

  void _updateTimeWatched(Duration elapsed) {
    if (_videoPlayerController.value.isPlaying) {
      final currentPosition = _videoPlayerController.value.position;
      final difference = currentPosition - _lastReportedPosition;
      _totalWatchedDuration += difference;
      _lastReportedPosition = currentPosition;
      widget.onTimeWatched(_totalWatchedDuration.inSeconds.toDouble() /
          _videoPlayerController.value.duration.inSeconds.toDouble());
    }
  }

  void _sendRating() {
    final totalDuration = _videoPlayerController.value.duration.inSeconds;
    final watchedDuration = _totalWatchedDuration.inSeconds;
    if (totalDuration > 0) {
      final timeWatched = watchedDuration / totalDuration;
      widget.onTimeWatched(timeWatched);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chewie(
          controller: _chewieController,
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
