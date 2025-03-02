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
      final movieResponse = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: {
          'language': 'tr-TR',
          'query': query,
          'with_original_language': 'tr|en',
        },
      );

      final tvResponse = await _dio.get(
        '$_baseUrl/search/tv',
        queryParameters: {
          'language': 'tr-TR',
          'query': query,
          'with_original_language': 'tr|en',
        },
      );

      // 6 ve üzeri puanlı ve en az 100 oy almış filmler
      final List<Map<String, dynamic>> movies = List<Map<String, dynamic>>.from(
        movieResponse.data['results'].where((item) =>
          (item['original_language'] == 'tr' || item['original_language'] == 'en') &&
          (item['vote_average'] ?? 0) >= 6.0 &&
          (item['vote_count'] ?? 0) >= 100
        ),
      );

      // 6 ve üzeri puanlı ve en az 100 oy almış diziler
      final List<Map<String, dynamic>> shows = List<Map<String, dynamic>>.from(
        tvResponse.data['results'].where((item) =>
          (item['original_language'] == 'tr' || item['original_language'] == 'en') &&
          (item['vote_average'] ?? 0) >= 6.0 &&
          (item['vote_count'] ?? 0) >= 100
        ),
      );

      // Sonuçları puana göre sırala (yüksekten düşüğe)
      movies.sort((a, b) => (b['vote_average'] ?? 0).compareTo(a['vote_average'] ?? 0));
      shows.sort((a, b) => (b['vote_average'] ?? 0).compareTo(a['vote_average'] ?? 0));

      return {
        'movies': movies,
        'shows': shows,
      };
    } catch (e) {
      print('Error searching content: $e');
      return {'movies': [], 'shows': []};
    }
  }

  Future<Map<String, dynamic>?> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId',
        queryParameters: {
          'language': 'tr-TR',
          'append_to_response': 'credits,videos,similar,genres',
        },
      );
      print(response.data); // API yanıtını konsola yazdır
      return response.data;
    } catch (e) {
      print('Error getting movie details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTVShowDetails(int tvId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tv/$tvId',
        queryParameters: {
          'language': 'tr-TR',
          'append_to_response': 'credits,videos,similar,genres',
        },
      );

      // Türleri çekelim
      final genreResponse = await _dio.get(
        '$_baseUrl/genre/tv/list',
        queryParameters: {
          'language': 'tr-TR',
        },
      );

      // Response'a türleri ekleyelim
      final data = response.data;
      data['genre_names'] = (data['genres'] as List?)?.map((genre) {
        final genreName = (genreResponse.data['genres'] as List)
            .firstWhere((g) => g['id'] == genre['id'], orElse: () => {'name': ''})['name'];
        return genreName;
      }).toList();

      return data;
    } catch (e) {
      print('Error getting TV show details: $e');
      return null;
    }
  }
} 