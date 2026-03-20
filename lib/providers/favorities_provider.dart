import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _ids = {};

  bool isFavorite(String id) => _ids.contains(id);

  Set<String> get ids => _ids;

  void toggleFavorite(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    notifyListeners();
  }
}