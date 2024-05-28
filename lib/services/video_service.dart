import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  static Future<List<Map<String, dynamic>>> fetchVideos() async {
    // Cambia la URL para obtener videos aleatorios desde el backend
    final response = await http.get(Uri.parse('http://192.168.152.208:5283/api/Pelicula/random/2'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Asegúrate de que la respuesta sea una lista de mapas
      final List<Map<String, dynamic>> videos = List<Map<String, dynamic>>.from(data);
      return videos;
    } else {
      throw Exception('Failed to load videos');
    }
  }

  static Future<void> sendRating(String userId, String videoId, double rating) async {
    final response = await http.post(
      Uri.parse('http://192.168.152.208:5000/calificaciones'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'usuarioId': userId,
        'peliculaId': videoId,
        'calificacion': rating,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to send rating');
    }
  }
}
