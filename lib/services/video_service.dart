// VideoService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  static Future<List<Map<String, dynamic>>> fetchVideos() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.103:5283/api/Pelicula/random/2'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> videos =
          List<Map<String, dynamic>>.from(data);
      return videos;
    } else {
      throw Exception('Failed to load videos');
    }
  }

  static Future<void> sendRating(
    String userId, String videoId, double rating, int timestamp) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.103:5283/api/Rating'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'usuarioId': userId,
          'peliculaId': videoId,
          'calificacion': rating,
          'timestamp': timestamp,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to send rating');
      }
    } catch (e) {
      print('Error sending rating: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> fetchRecommendation(String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('http://192.168.1.103:4000/recomendar/$userId?t=$timestamp'),
    );
    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      print('Raw API response: $data'); // Log the raw response
      final recommendedMovie = data['pelicula_recomendada'];
      print(
          'Recommended movie: $recommendedMovie'); // Log the recommended movie
      if (recommendedMovie != null &&
          recommendedMovie['id'] != null &&
          recommendedMovie['titulo'] != null &&
          recommendedMovie['videoUrl'] != null &&
          recommendedMovie['generos'] != null) {
        return Map<String, dynamic>.from(recommendedMovie);
      } else {
        throw Exception('Invalid data received');
      }
    } else {
      throw Exception('Failed to load recommendation');
    }
  }
}
