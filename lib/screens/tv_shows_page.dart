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

  @override
  void initState() {
    super.initState();
    _loadTVShows();
  }

  Future<void> _loadTVShows() async {
    final shows = await _tmdbService.getPopularTVShows();
    setState(() {
      _tvShows = shows;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diziler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _tvShows.length,
              itemBuilder: (context, index) {
                final show = _tvShows[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      'https://image.tmdb.org/t/p/w92${show['poster_path']}',
                      width: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.tv),
                    ),
                    title: Text(
                      show['name'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      show['first_air_date'] ?? 'Tarih belirtilmemiş',
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