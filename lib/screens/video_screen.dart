import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:recomendator_app/screens/video_player_widget.dart';
import 'package:recomendator_app/services/video_service.dart';

class VideoScreen extends StatefulWidget {
  final String username;
  final String userId;

  const VideoScreen({Key? key, required this.username, required this.userId})
      : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late Future<List<Map<String, dynamic>>> _videos;
  List<Map<String, dynamic>> _videoList = [];
  bool _isLoading = false;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final cacheManager = DefaultCacheManager();
  double _timeWatched = 0;
  final Set<String> _ratedVideos = {};

  @override
  void initState() {
    super.initState();
    _videos = VideoService.fetchVideos();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final videos = await _videos;
      setState(() {
        _videoList = videos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) async {
    if (_currentIndex < _videoList.length) {
      await _sendRating(_videoList[_currentIndex]['id']);
      setState(() {
        _timeWatched = 0;
      });
    }
    setState(() {
      _currentIndex = index;
    });

    if (_currentIndex >= _videoList.length) {
      await _loadRecommendation();
    }
  }

  Future<void> _sendRating(String? videoId) async {
    if (videoId == null) {
      print('Invalid video ID');
      return;
    }

    final String key = '${widget.userId}:$videoId';
    if (_ratedVideos.contains(key)) {
      print('User has already rated this video.');
      return;
    }

    double rating = _calculateRating(_timeWatched);
    try {
      await VideoService.sendRating(widget.userId, videoId, rating,
          DateTime.now().millisecondsSinceEpoch);
      _ratedVideos.add(key);
    } catch (e) {
      print('Error sending rating: $e');
    }
  }

  double _calculateRating(double timeWatched) {
    return timeWatched * 5.0;
  }

  void _updateTimeWatched(double time) {
    setState(() {
      _timeWatched = time;
    });
  }

  Future<void> _loadRecommendation() async {
    try {
      final recommendation = await VideoService.fetchRecommendation(widget.userId);
      setState(() {
        _videoList.add(recommendation);
      });
    } catch (e) {
      print('Error loading recommendation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomendator Videos'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
              ),
              child: Text(
                widget.userId,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _videoList.length + 1,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                if (index >= _videoList.length) {
                  return Center(
                    child: Text(
                      'No hay más videos',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                } else {
                  final video = _videoList[index];
                  final videoUrl = video['videoUrl'];
                  final title = video['titulo'];
                  final videoId = video['id'];

                  if (videoUrl == null || title == null || videoId == null) {
                    print('Invalid data found: $video');
                    return Center(
                      child: Text(
                        'Invalid video data',
                        style: TextStyle(color: Colors.red, fontSize: 24),
                      ),
                    );
                  }

                  return VideoPlayerWidget(
                    key: ValueKey(videoUrl),
                    videoUrl: videoUrl,
                    title: title,
                    userId: widget.userId,
                    videoId: videoId,
                    cacheManager: cacheManager,
                    isCurrent: index == _currentIndex,
                    onTimeWatched: _updateTimeWatched,
                  );
                }
              },
            ),
    );
  }
}
