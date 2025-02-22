import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';

  TMDBService() {
    _dio.options.headers['Authorization'] = 'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}';
  }

  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    try {
      final response = await _dio.get('$_baseUrl/movie/popular');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } catch (e) {
      print('Error getting popular movies: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPopularTVShows() async {
    try {
      final response = await _dio.get('$_baseUrl/tv/popular');
      return List<Map<String, dynamic>>.from(response.data['results']);
    } catch (e) {
      print('Error getting popular TV shows: $e');
      return [];
    }
  }
} 