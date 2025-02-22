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
  String _currentSort = 'popularity.desc';
  String _currentType = 'popular';

  final Map<String, String> _filterOptions = {
    'popular': 'Popüler Filmler',
    'top_rated': 'En Çok Oy Alan Filmler',
    'discover': 'Keşfet',
  };

  final Map<String, String> _sortOptions = {
    'popularity.desc': 'Popülerlik (Azalan)',
    'vote_average.desc': 'Puan (Yüksek → Düşük)',
    'vote_average.asc': 'Puan (Düşük → Yüksek)',
    'vote_count.desc': 'Oy Sayısı (Azalan)',
    'release_date.desc': 'Yeni Çıkanlar',
    'release_date.asc': 'Eski Çıkanlar',
  };

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

    final result = await _tmdbService.getMovies(
      type: _currentType,
      sortBy: _currentSort,
      voteAverageGte: _currentSort.contains('vote_average') ? 0.0 : null,
    );
    
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
        title: const Text('Filmler'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _currentType = value;
              });
              _loadMovies(reset: true);
            },
            itemBuilder: (BuildContext context) {
              return _filterOptions.entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList();
            },
          ),
          if (_currentType == 'discover')
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (String value) {
                setState(() {
                  _currentSort = value;
                });
                _loadMovies(reset: true);
              },
              itemBuilder: (BuildContext context) {
                return _sortOptions.entries.map((entry) {
                  return PopupMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
        ],
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