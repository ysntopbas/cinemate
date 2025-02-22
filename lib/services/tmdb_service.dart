import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';
  int _currentMoviePage = 1;
  int _currentTVPage = 1;

  TMDBService() {
    _dio.options.headers['Authorization'] = 'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}';
  }

  Future<Map<String, dynamic>> getMovies({
    required String type,
    String sortBy = 'popularity.desc',
    double? voteAverageGte,
    int? voteCountGte,
  }) async {
    try {
      String endpoint;
      switch (type) {
        case 'top_rated':
          endpoint = '$_baseUrl/movie/top_rated';
          break;
        case 'popular':
          endpoint = '$_baseUrl/movie/popular';
          break;
        case 'discover':
        default:
          endpoint = '$_baseUrl/discover/movie';
          break;
      }

      final Map<String, dynamic> queryParams = {
        'language': 'tr-TR',
        'page': _currentMoviePage,
      };

      if (type == 'discover') {
        queryParams['sort_by'] = sortBy;
        if (voteAverageGte != null) {
          queryParams['vote_average.gte'] = voteAverageGte;
        }
        if (voteCountGte != null) {
          queryParams['vote_count.gte'] = voteCountGte;
        }
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      
      final List<Map<String, dynamic>> filteredResults = 
        List<Map<String, dynamic>>.from(response.data['results'])
          .where((movie) => 
            movie['original_language'] == 'tr' || 
            movie['original_language'] == 'en')
          .toList();
      
      return {
        'movies': filteredResults,
        'hasMore': response.data['page'] < response.data['total_pages'],
        'currentPage': response.data['page'],
        'totalPages': response.data['total_pages'],
      };
    } catch (e) {
      print('Error getting movies: $e');
      return {'movies': [], 'hasMore': false, 'currentPage': 1, 'totalPages': 1};
    }
  }

  Future<Map<String, dynamic>> getTVShows({
    required String type,
    String sortBy = 'popularity.desc',
    double? voteAverageGte,
    int? voteCountGte,
  }) async {
    try {
      String endpoint;
      switch (type) {
        case 'top_rated':
          endpoint = '$_baseUrl/tv/top_rated';
          break;
        case 'popular':
          endpoint = '$_baseUrl/tv/popular';
          break;
        case 'discover':
        default:
          endpoint = '$_baseUrl/discover/tv';
          break;
      }

      final Map<String, dynamic> queryParams = {
        'language': 'tr-TR',
        'page': _currentTVPage,
      };

      if (type == 'discover') {
        queryParams['sort_by'] = sortBy;
        if (voteAverageGte != null) {
          queryParams['vote_average.gte'] = voteAverageGte;
        }
        if (voteCountGte != null) {
          queryParams['vote_count.gte'] = voteCountGte;
        }
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      
      final List<Map<String, dynamic>> filteredResults = 
        List<Map<String, dynamic>>.from(response.data['results'])
          .where((show) => 
            show['original_language'] == 'tr' || 
            show['original_language'] == 'en')
          .toList();
      
      return {
        'shows': filteredResults,
        'hasMore': response.data['page'] < response.data['total_pages'],
        'currentPage': response.data['page'],
        'totalPages': response.data['total_pages'],
      };
    } catch (e) {
      print('Error getting TV shows: $e');
      return {'shows': [], 'hasMore': false, 'currentPage': 1, 'totalPages': 1};
    }
  }

  void nextMoviePage() {
    _currentMoviePage++;
  }

  void nextTVPage() {
    _currentTVPage++;
  }

  void resetPages() {
    _currentMoviePage = 1;
    _currentTVPage = 1;
  }

  Future<Map<String, dynamic>> searchContent(String query) async {
    try {
      final Map<String, dynamic> movieParams = {
        'language': 'tr-TR',
        'query': query,
        'region': 'TR',
        'with_original_language': 'tr|en',
      };

      final Map<String, dynamic> tvParams = {
        'language': 'tr-TR',
        'query': query,
        'region': 'TR',
        'with_original_language': 'tr|en',
      };

      final movieResponse = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: movieParams,
      );

      final tvResponse = await _dio.get(
        '$_baseUrl/search/tv',
        queryParameters: tvParams,
      );

      final List<Map<String, dynamic>> movies = List<Map<String, dynamic>>.from(
        movieResponse.data['results'].where((item) {
          return item['original_language'] == 'tr' || 
                 item['original_language'] == 'en';
        }),
      );

      final List<Map<String, dynamic>> shows = List<Map<String, dynamic>>.from(
        tvResponse.data['results'].where((item) {
          return item['original_language'] == 'tr' || 
                 item['original_language'] == 'en';
        }),
      );

      return {
        'movies': movies,
        'shows': shows,
      };
    } catch (e) {
      print('Error searching content: $e');
      return {'movies': [], 'shows': []};
    }
  }
} 