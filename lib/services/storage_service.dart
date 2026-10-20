import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../models/watch_progress.dart';

class StorageService {
  static const String _favoritesKey = 'streambox_favorites';
  static const String _progressKey = 'streambox_progress';
  static const String _catalogUrlKey = 'streambox_catalog_url';
  static const String _cachedCatalogKey = 'streambox_cached_catalog';
  static const String _localItemsKey = 'streambox_local_items';

  static const String defaultCatalogUrl =
      'https://raw.githubusercontent.com/danielgarciagonzalezarmenia-ai/streambox/main/catalog.json';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Favorites (Mi Lista) ---
  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> isFavorite(String id) async {
    return getFavorites().contains(id);
  }

  Future<void> toggleFavorite(String id) async {
    final list = getFavorites();
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _prefs.setStringList(_favoritesKey, list);
  }

  // --- Watch Progress ---
  List<WatchProgress> getAllWatchProgress() {
    final raw = _prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => WatchProgress.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  WatchProgress? getProgress(String mediaId) {
    final all = getAllWatchProgress();
    final matches = all.where((p) => p.mediaId == mediaId);
    return matches.isNotEmpty ? matches.first : null;
  }

  Future<void> saveProgress(WatchProgress progress) async {
    final all = getAllWatchProgress();
    all.removeWhere((p) => p.mediaId == progress.mediaId);
    all.insert(0, progress);
    // Keep max 30 items
    if (all.length > 30) {
      all.removeRange(30, all.length);
    }
    final raw = jsonEncode(all.map((e) => e.toJson()).toList());
    await _prefs.setString(_progressKey, raw);
  }

  Future<void> clearProgress(String mediaId) async {
    final all = getAllWatchProgress();
    all.removeWhere((p) => p.mediaId == mediaId);
    final raw = jsonEncode(all.map((e) => e.toJson()).toList());
    await _prefs.setString(_progressKey, raw);
  }

  // --- Remote Catalog URL ---
  String getCatalogUrl() {
    return _prefs.getString(_catalogUrlKey) ?? defaultCatalogUrl;
  }

  Future<void> setCatalogUrl(String url) async {
    await _prefs.setString(_catalogUrlKey, url.trim());
  }

  // --- Cached Catalog JSON ---
  String? getCachedCatalogJson() {
    return _prefs.getString(_cachedCatalogKey);
  }

  Future<void> setCachedCatalogJson(String jsonString) async {
    await _prefs.setString(_cachedCatalogKey, jsonString);
  }

  // --- Local Added Items (In-App additions) ---
  List<MediaItem> getLocalItems() {
    final raw = _prefs.getString(_localItemsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => MediaItem.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addLocalItem(MediaItem item) async {
    final list = getLocalItems();
    list.removeWhere((i) => i.id == item.id);
    list.insert(0, item);
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_localItemsKey, raw);
  }

  Future<void> deleteLocalItem(String id) async {
    final list = getLocalItems();
    list.removeWhere((i) => i.id == id);
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_localItemsKey, raw);
  }
}
