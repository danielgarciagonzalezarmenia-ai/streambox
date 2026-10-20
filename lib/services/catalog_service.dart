import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import 'storage_service.dart';

class CatalogService extends ChangeNotifier {
  final StorageService storageService;

  List<MediaItem> _items = [];
  MediaItem? _featuredItem;
  List<String> _categories = [];
  bool _isLoading = false;
  String? _lastError;
  DateTime? _lastSyncTime;

  CatalogService({required this.storageService});

  List<MediaItem> get items => List.unmodifiable(_items);
  MediaItem? get featuredItem => _featuredItem;
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  List<MediaItem> get movies => _items.where((i) => i.isMovie).toList();
  List<MediaItem> get series => _items.where((i) => i.isSeries).toList();

  Future<void> initialize() async {
    // 1. First, load from cache or bundled asset instantly for 0-second launch
    await _loadFromCacheOrAsset();

    // 2. Then attempt silent remote sync
    await syncRemote(silent: true);
  }

  Future<void> _loadFromCacheOrAsset() async {
    final cached = storageService.getCachedCatalogJson();
    if (cached != null && cached.isNotEmpty) {
      try {
        _parseCatalogJson(cached, isRemote: false);
        return;
      } catch (_) {
        // Corrupted cache, fallback to asset
      }
    }

    try {
      final bundled =
          await rootBundle.loadString('assets/catalog/default_catalog.json');
      _parseCatalogJson(bundled, isRemote: false);
    } catch (e) {
      debugPrint('Error loading default catalog asset: $e');
    }
  }

  Future<bool> syncRemote({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
    }

    final url = storageService.getCatalogUrl();
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        _parseCatalogJson(body, isRemote: true);
        await storageService.setCachedCatalogJson(body);
        _lastSyncTime = DateTime.now();
        _lastError = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _lastError = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      _lastError = 'Error de conexión: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void _parseCatalogJson(String jsonStr, {required bool isRemote}) {
    try {
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return;

      final rawItems = decoded['items'] as List<dynamic>? ?? [];
      final rawCategories = decoded['categories'] as List<dynamic>? ?? [];
      final featuredId = decoded['featuredId']?.toString();

      final parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map((m) => MediaItem.fromJson(m))
          .toList();

      // Merge local items added on the phone
      final localItems = storageService.getLocalItems();
      final mergedMap = <String, MediaItem>{};

      for (final item in parsedItems) {
        mergedMap[item.id] = item;
      }
      for (final local in localItems) {
        mergedMap[local.id] = local;
      }

      _items = mergedMap.values.toList();

      // Collect categories
      final catSet = <String>{};
      for (final c in rawCategories) {
        catSet.add(c.toString());
      }
      for (final item in _items) {
        catSet.addAll(item.categories);
        if (item.genre.isNotEmpty) catSet.add(item.genre);
      }
      _categories = catSet.toList();

      // Determine featured item
      if (featuredId != null && mergedMap.containsKey(featuredId)) {
        _featuredItem = mergedMap[featuredId];
      } else if (_items.isNotEmpty) {
        _featuredItem = _items.first;
      }
    } catch (e) {
      debugPrint('Catalog parsing error: $e');
    }
  }

  MediaItem? getById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  List<MediaItem> getByCategory(String category) {
    if (category.toLowerCase() == 'películas' ||
        category.toLowerCase() == 'peliculas') {
      return movies;
    }
    if (category.toLowerCase() == 'series') {
      return series;
    }
    return _items.where((item) {
      return item.categories.any(
            (c) => c.toLowerCase() == category.toLowerCase(),
          ) ||
          item.genre.toLowerCase() == category.toLowerCase();
    }).toList();
  }

  List<MediaItem> search(String query, {String? typeFilter}) {
    final q = query.trim().toLowerCase();
    return _items.where((item) {
      if (typeFilter != null && typeFilter.isNotEmpty) {
        if (typeFilter == 'movie' && !item.isMovie) return false;
        if (typeFilter == 'series' && !item.isSeries) return false;
      }
      if (q.isEmpty) return true;
      final matchTitle = item.title.toLowerCase().contains(q);
      final matchGenre = item.genre.toLowerCase().contains(q);
      final matchDesc = item.description.toLowerCase().contains(q);
      return matchTitle || matchGenre || matchDesc;
    }).toList();
  }

  Future<void> addLocalMediaItem(MediaItem item) async {
    await storageService.addLocalItem(item);
    _items.removeWhere((i) => i.id == item.id);
    _items.insert(0, item);
    if (!_categories.contains(item.genre)) {
      _categories.add(item.genre);
    }
    notifyListeners();
  }

  Future<void> deleteLocalMediaItem(String id) async {
    await storageService.deleteLocalItem(id);
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
