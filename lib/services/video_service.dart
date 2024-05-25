import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  static Future<List<Map<String, dynamic>>> fetchVideos() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.106:5283/api/Pelicula'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>().toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
