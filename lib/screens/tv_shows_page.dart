import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class TVShowsPage extends StatefulWidget {
  const TVShowsPage({super.key});

  @override
  State<TVShowsPage> createState() => _TVShowsPageState();
}

class _TVShowsPageState extends State<TVShowsPage> {
  final TMDBService _tmdbService = TMDBService();
  List<Map<String, dynamic>> _tvShows = [];
  bool _isLoading = true;
  bool _hasMore = true;
  String _currentSort = 'popularity.desc';
  String _currentType = 'popular';

  final Map<String, String> _filterOptions = {
    'popular': 'Popüler Diziler',
    'top_rated': 'En Çok Oy Alan Diziler',
    'discover': 'Keşfet',
  };

  final Map<String, String> _sortOptions = {
    'popularity.desc': 'Popülerlik (Azalan)',
    'vote_average.desc': 'Puan (Yüksek → Düşük)',
    'vote_average.asc': 'Puan (Düşük → Yüksek)',
    'vote_count.desc': 'Oy Sayısı (Azalan)',
    'first_air_date.desc': 'Yeni Çıkanlar',
    'first_air_date.asc': 'Eski Çıkanlar',
  };

  @override
  void initState() {
    super.initState();
    _loadTVShows();
  }

  Future<void> _loadTVShows({bool reset = false}) async {
    if (reset) {
      setState(() {
        _tvShows = [];
        _tmdbService.resetPages();
      });
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _tmdbService.getTVShows(
      type: _currentType,
      sortBy: _currentSort,
      voteAverageGte: _currentSort.contains('vote_average') ? 0.0 : null,
    );
    
    setState(() {
      if (reset) {
        _tvShows = List<Map<String, dynamic>>.from(result['shows']);
      } else {
        _tvShows.addAll(List<Map<String, dynamic>>.from(result['shows']));
      }
      _hasMore = result['hasMore'];
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    _tmdbService.nextTVPage();
    await _loadTVShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diziler'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _currentType = value;
              });
              _loadTVShows(reset: true);
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
                _loadTVShows(reset: true);
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
          itemCount: _tvShows.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _tvShows.length) {
              return Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: _loadMore,
                        child: const Text('Daha Fazla Yükle'),
                      ),
              );
            }

            final show = _tvShows[index];
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
                            'https://image.tmdb.org/t/p/w500${show['poster_path']}',
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
                          show['name'] ?? '',
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
                              '${(show['vote_average'] ?? 0).toStringAsFixed(1)}',
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