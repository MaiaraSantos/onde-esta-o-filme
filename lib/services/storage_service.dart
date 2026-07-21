import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/media_item.dart';

class StorageService {
  static const String _watchlistKey = 'watchlist_items';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Recupera todos os itens da watchlist
  List<MediaItem> getWatchlist() {
    final List<String>? jsonList = _prefs.getStringList(_watchlistKey);
    if (jsonList == null) return [];

    return jsonList.map((itemStr) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(itemStr);
        return MediaItem.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }).whereType<MediaItem>().toList();
  }

  // Salva a lista completa de volta para as preferências locais
  Future<bool> _saveWatchlist(List<MediaItem> list) async {
    final List<String> jsonList = list.map((item) => json.encode(item.toJson())).toList();
    return await _prefs.setStringList(_watchlistKey, jsonList);
  }

  // Adiciona um item à watchlist
  Future<bool> addToWatchlist(MediaItem item) async {
    final List<MediaItem> currentList = getWatchlist();
    if (currentList.any((e) => e.id == item.id)) return true; // Já está na lista

    currentList.add(item);
    return await _saveWatchlist(currentList);
  }

  // Remove um item da watchlist por ID
  Future<bool> removeFromWatchlist(String id) async {
    final List<MediaItem> currentList = getWatchlist();
    currentList.removeWhere((e) => e.id == id);
    return await _saveWatchlist(currentList);
  }

  // Verifica se o item já está favoritado
  bool isInWatchlist(String id) {
    final List<MediaItem> currentList = getWatchlist();
    return currentList.any((e) => e.id == id);
  }
}
