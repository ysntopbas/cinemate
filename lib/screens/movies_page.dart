import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final TMDBService _tmdbService = TMDBService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final movies = await _tmdbService.getPopularMovies();
    setState(() {
      _movies = movies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                      width: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.movie),
                    ),
                    title: Text(
                      movie['title'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      movie['release_date'] ?? 'Tarih belirtilmemiş',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 