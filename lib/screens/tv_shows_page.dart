import 'package:cinemate/screens/content_details_page.dart';
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
  List<dynamic> watchlist = [];
  List<dynamic> watchedList = [];

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

    final result = await _tmdbService.getTVShows(type: 'top_rated');
    
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
        title: const Text('En İyi Diziler'),
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
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContentDetailsPage(
                        content: show,
                        isMovie: false,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Column(
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
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              watchlist.contains(show['id'])
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              setState(() {
                                final showId = show['id'];
                                if (watchlist.contains(showId)) {
                                  watchlist.remove(showId);
                                } else {
                                  watchlist.add(showId);
                                  watchedList.remove(showId);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              watchedList.contains(show['id'])
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              setState(() {
                                final showId = show['id'];
                                if (watchedList.contains(showId)) {
                                  watchedList.remove(showId);
                                } else {
                                  watchedList.add(showId);
                                  watchlist.remove(showId);
                                }
                              });
                            },
                          ),
                          if (watchedList.contains(show['id'])) ...[
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up_outlined,
                                color: show['liked'] == true
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  show['liked'] = true;
                                  show['disliked'] = false;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down_outlined,
                                color: show['disliked'] == true
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  show['liked'] = false;
                                  show['disliked'] = true;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 