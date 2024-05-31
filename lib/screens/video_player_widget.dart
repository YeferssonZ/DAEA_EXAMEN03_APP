import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:recomendator_app/services/video_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String userId;
  final String videoId;
  final bool isCurrent;
  final BaseCacheManager cacheManager;
  final ValueChanged<double> onTimeWatched;
  final bool autoPlay; // Nuevo

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.userId,
    required this.videoId,
    required this.cacheManager,
    required this.isCurrent,
    required this.onTimeWatched,
    this.autoPlay = false, // Nuevo
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isVideoCompleted = false;
  double _startTime = 0;
  bool _isDisposed = false;
  bool _hasSentRating = false;
  bool _userSeeked = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl || widget.isCurrent != oldWidget.isCurrent) {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      }
      _initializePlayer();
    } else if (widget.isCurrent && !_videoPlayerController.value.isPlaying) {
      _videoPlayerController.play();
    } else if (!widget.isCurrent && _videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      _sendRating();
    }
  }

  void _initializePlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      looping: false,
      aspectRatio: 16 / 9,
      autoPlay: widget.autoPlay, // Cambiado a widget.autoPlay
      allowMuting: true,
      placeholder: Center(
        child: CircularProgressIndicator(),
      ),
      allowPlaybackSpeedChanging: false,
    );

    _videoPlayerController.addListener(() async {
      if (_videoPlayerController.value.position == _videoPlayerController.value.duration &&
          _videoPlayerController.value.position != Duration.zero &&
          !_isVideoCompleted) {
        _sendRating(complete: true);
        setState(() {
          _isVideoCompleted = true;
        });
        _chewieController.pause();
      }

      if (_videoPlayerController.value.isPlaying && _startTime == 0) {
        _startTime = _videoPlayerController.value.position.inSeconds.toDouble();
      }

      if (_videoPlayerController.value.isInitialized &&
          !_videoPlayerController.value.isPlaying &&
          !_isVideoCompleted &&
          !_videoPlayerController.value.isBuffering &&
          _videoPlayerController.value.position != Duration.zero &&
          !_userSeeked &&
          _videoPlayerController.value.position.inSeconds > _startTime) {
        _sendRating();
      }

      if (_videoPlayerController.value.isPlaying && _videoPlayerController.value.position.inSeconds < _startTime) {
        _userSeeked = true;
      }
    });
  }

  void _sendRating({bool complete = false}) async {
    final double endTime = _videoPlayerController.value.position.inSeconds.toDouble();
    final double timeWatched = (endTime - _startTime);
    if (!_hasSentRating && timeWatched > 0 && !_userSeeked) {
      widget.onTimeWatched(timeWatched);
      final double rating = complete ? 5.0 : (timeWatched / _videoPlayerController.value.duration.inSeconds.toDouble()) * 5;
      try {
        await VideoService.sendRating(widget.userId, widget.videoId, double.parse(rating.toStringAsFixed(1)));
        _hasSentRating = true;
      } catch (e) {
        if (!_isDisposed) {
          setState(() {
            print('Error sending rating: $e');
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
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
