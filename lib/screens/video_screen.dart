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
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final cacheManager = DefaultCacheManager();
  double _timeWatched = 0;

  @override
  void initState() {
    super.initState();
    _videos = VideoService.fetchVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) async {
    try {
      final videos = await _videos;
      if (_timeWatched > 0 && _currentIndex < videos.length) {
        final double rating = (_timeWatched / videos[_currentIndex]['duration'].toDouble()) * 5.0;
        await VideoService.sendRating(widget.userId, videos[_currentIndex]['id'], double.parse(rating.toStringAsFixed(1)));
        _timeWatched = 0;
      }
      setState(() {
        _currentIndex = index;
      });
    } catch (e) {
      print('Error on page change: $e');
    }
  }

  void _updateTimeWatched(double time) {
    if (time > 0) {
      _timeWatched = time;
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No videos found'));
          } else {
            final List<Map<String, dynamic>> videos = snapshot.data!;
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length + 1,  // Add one more item for the empty view
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                if (index >= videos.length) {
                  return Center(
                    child: Text(
                      'No hay más videos',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                } else {
                  return VideoPlayerWidget(
                    key: ValueKey(videos[index]['videoUrl']),
                    videoUrl: videos[index]['videoUrl'],
                    title: videos[index]['titulo'],
                    userId: widget.userId,
                    videoId: videos[index]['id'],
                    cacheManager: cacheManager,
                    isCurrent: index == _currentIndex,
                    onTimeWatched: _updateTimeWatched,
                    autoPlay: index == _currentIndex, // Reproducir automáticamente el video actual
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
