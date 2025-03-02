import 'package:cinemate/providers/watch_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'movies_page.dart';
import 'tv_shows_page.dart';
import 'search_page.dart';
import 'package:provider/provider.dart';
import 'package:cinemate/services/tmdb_service.dart';
import 'content_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> watchlist = [];
  final List<String> watchedList = [];
  bool isWatchlistExpanded = false;
  bool isWatchedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final watchListProvider = Provider.of<WatchListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'CineMate',
                style: GoogleFonts.fleurDeLeah(
                  fontSize: 72,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Filmler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoviesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: const Text('Diziler'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TVShowsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Ara'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İzleme Listesi Bölümü
            Text(
              'İzleme Listesi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  if (watchListProvider.watchlist.isEmpty)
                    Center(
                      child: Text(
                        'Henüz izleme listenize film/dizi eklemediniz',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: watchListProvider.watchlist.length,
                      itemBuilder: (context, index) {
                        final movieId = watchListProvider.watchlist[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: TMDBService().getMovieDetails(movieId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Text('Hata oluştu');
                            }
                            final movie = snapshot.data!;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentDetailsPage(
                                      content: movie,
                                      isMovie: true,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Row(
                                  children: [
                                    Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                      width: 100,
                                      height: 150,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(movie['title'] ?? ''),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // İzlediklerim Listesi Bölümü
            Text(
              'İzlediklerim',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  if (watchListProvider.watchedList.isEmpty)
                    Center(
                      child: Text(
                        'Henüz izlediğiniz film/dizi eklemediniz',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: watchListProvider.watchedList.length,
                      itemBuilder: (context, index) {
                        final showId = watchListProvider.watchedList[index];
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: TMDBService().getTVShowDetails(showId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Text('Hata oluştu');
                            }
                            final show = snapshot.data!;
                            return GestureDetector(
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
                              child: Card(
                                child: Row(
                                  children: [
                                    Image.network(
                                      'https://image.tmdb.org/t/p/w500${show['poster_path']}',
                                      width: 100,
                                      height: 150,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(show['name'] ?? ''),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 