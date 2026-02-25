import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<String> _favoriteIds = [];

  List<String> get favorites => List.unmodifiable(_favoriteIds);

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
}