import 'package:flutter/foundation.dart';

class WatchListProvider with ChangeNotifier {
  final List<int> _watchlist = [];
  final List<int> _watchedList = [];
  final Map<int, bool> _likedContent = {};
  final Map<int, bool> _dislikedContent = {};

  List<int> get watchlist => _watchlist;
  List<int> get watchedList => _watchedList;

  bool isInWatchlist(int id) => _watchlist.contains(id);
  bool isWatched(int id) => _watchedList.contains(id);
  bool isLiked(int id) => _likedContent[id] ?? false;
  bool isDisliked(int id) => _dislikedContent[id] ?? false;

  void toggleWatchlist(int id) {
    if (_watchlist.contains(id)) {
      _watchlist.remove(id);
    } else {
      _watchlist.add(id);
      _watchedList.remove(id);
    }
    notifyListeners();
  }

  void toggleWatched(int id) {
    if (_watchedList.contains(id)) {
      _watchedList.remove(id);
      _likedContent.remove(id);
      _dislikedContent.remove(id);
    } else {
      _watchedList.add(id);
      _watchlist.remove(id);
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