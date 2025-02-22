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
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies({bool reset = false}) async {
    if (reset) {
      setState(() {
        _movies = [];
        _tmdbService.resetPages();
      });
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _tmdbService.getMovies(type: 'top_rated');
    
    setState(() {
      if (reset) {
        _movies = List<Map<String, dynamic>>.from(result['movies']);
      } else {
        _movies.addAll(List<Map<String, dynamic>>.from(result['movies']));
      }
      _hasMore = result['hasMore'];
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    _tmdbService.nextMoviePage();
    await _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('En İyi Filmler'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMore();
          }
          return true;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _movies.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _movies.length) {
              return Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: _loadMore,
                        child: const Text('Daha Fazla Yükle'),
                      ),
              );
            }

            final movie = _movies[index];
            return Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie['title'] ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(movie['vote_average'] ?? 0).toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 