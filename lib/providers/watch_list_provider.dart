import 'package:flutter/foundation.dart';

class WatchListProvider with ChangeNotifier {
  final List<int> _movieWatchlist = [];
  final List<int> _tvShowWatchlist = [];
  final List<int> _watchedMovies = [];
  final List<int> _watchedTVShows = [];
  final Map<int, bool> _likedContent = {};
  final Map<int, bool> _dislikedContent = {};

  List<int> get movieWatchlist => _movieWatchlist;
  List<int> get tvShowWatchlist => _tvShowWatchlist;
  List<int> get watchedMovies => _watchedMovies;
  List<int> get watchedTVShows => _watchedTVShows;

  bool isInMovieWatchlist(int id) => _movieWatchlist.contains(id);
  bool isInTVShowWatchlist(int id) => _tvShowWatchlist.contains(id);
  bool isWatchedMovie(int id) => _watchedMovies.contains(id);
  bool isWatchedTVShow(int id) => _watchedTVShows.contains(id);
  bool isLiked(int id) => _likedContent[id] ?? false;
  bool isDisliked(int id) => _dislikedContent[id] ?? false;

  void toggleMovieWatchlist(int id) {
    if (_movieWatchlist.contains(id)) {
      _movieWatchlist.remove(id);
    } else {
      _movieWatchlist.add(id);
      _tvShowWatchlist.remove(id);
    }
    notifyListeners();
  }

  void toggleTVShowWatchlist(int id) {
    if (_tvShowWatchlist.contains(id)) {
      _tvShowWatchlist.remove(id);
    } else {
      _tvShowWatchlist.add(id);
      _movieWatchlist.remove(id);
    }
    notifyListeners();
  }

  void toggleWatchedMovie(int id) {
    if (_watchedMovies.contains(id)) {
      _watchedMovies.remove(id);
      _likedContent.remove(id);
      _dislikedContent.remove(id);
    } else {
      _watchedMovies.add(id);
      _movieWatchlist.remove(id);
    }
    notifyListeners();
  }

  void toggleWatchedTVShow(int id) {
    if (_watchedTVShows.contains(id)) {
      _watchedTVShows.remove(id);
      _likedContent.remove(id);
      _dislikedContent.remove(id);
    } else {
      _watchedTVShows.add(id);
      _tvShowWatchlist.remove(id);
    }
    notifyListeners();
  }

  void setLiked(int id, bool value) {
    if (value) {
      _likedContent[id] = true;
      _dislikedContent[id] = false;
    } else {
      _likedContent.remove(id);
    }
    notifyListeners();
  }

  void setDisliked(int id, bool value) {
    if (value) {
      _dislikedContent[id] = true;
      _likedContent[id] = false;
    } else {
      _dislikedContent.remove(id);
    }
    notifyListeners();
  }
} 