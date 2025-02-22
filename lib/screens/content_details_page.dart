import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class ContentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> content;
  final bool isMovie;

  const ContentDetailsPage({
    super.key,
    required this.content,
    required this.isMovie,
  });

  @override
  State<ContentDetailsPage> createState() => _ContentDetailsPageState();
}

class _ContentDetailsPageState extends State<ContentDetailsPage> {
  final TMDBService _tmdbService = TMDBService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details = widget.isMovie
        ? await _tmdbService.getMovieDetails(widget.content['id'])
        : await _tmdbService.getTVShowDetails(widget.content['id']);

    setState(() {
      _details = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.isMovie
                          ? widget.content['title'] ?? ''
                          : widget.content['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    background: Image.network(
                      'https://image.tmdb.org/t/p/w500${_details?['backdrop_path'] ?? widget.content['backdrop_path']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 120,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://image.tmdb.org/t/p/w500${widget.content['poster_path']}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(widget.content['vote_average'] ?? 0).toStringAsFixed(1)}',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '(${widget.content['vote_count']} oy)',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.isMovie
                                        ? 'Çıkış Tarihi: ${widget.content['release_date'] ?? 'Belirtilmemiş'}'
                                        : 'İlk Yayın: ${widget.content['first_air_date'] ?? 'Belirtilmemiş'}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_details?['genre_names'] != null) ...[
                          Wrap(
                            spacing: 8,
                            children: (_details!['genre_names'] as List).map((genre) {
                              return Chip(
                                label: Text(
                                  genre.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Özet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.content['overview'] ?? 'Özet bulunmuyor.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (_details != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Oyuncular',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (_details?['credits']?['cast'] as List?)?.length ?? 0,
                              itemBuilder: (context, index) {
                                final cast = (_details?['credits']?['cast'] as List)[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: cast['profile_path'] != null
                                            ? NetworkImage(
                                                'https://image.tmdb.org/t/p/w200${cast['profile_path']}',
                                              )
                                            : null,
                                        child: cast['profile_path'] == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cast['name'] ?? '',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 