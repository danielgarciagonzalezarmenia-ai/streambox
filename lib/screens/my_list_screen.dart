import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import '../services/catalog_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class MyListScreen extends StatefulWidget {
  final CatalogService catalogService;
  final StorageService storageService;

  const MyListScreen({
    super.key,
    required this.catalogService,
    required this.storageService,
  });

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<MediaItem> _savedItems = [];

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  void _loadList() {
    final favIds = widget.storageService.getFavorites();
    final list = <MediaItem>[];
    for (final id in favIds) {
      final item = widget.catalogService.getById(id);
      if (item != null) {
        list.add(item);
      }
    }
    setState(() {
      _savedItems = list;
    });
  }

  void _openDetail(MediaItem item) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => DetailScreen(
          item: item,
          storageService: widget.storageService,
        ),
      ),
    ).then((_) => _loadList());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Mi Lista',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: Color(0xCC000000),
      ),
      child: SafeArea(
        child: _savedItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.bookmark,
                        size: 40,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tu lista está vacía',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Agrega películas y series tocando el botón "+ Mi Lista" en cualquier portada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: _savedItems.length,
                itemBuilder: (context, index) {
                  final item = _savedItems[index];
                  return MediaCard(
                    item: item,
                    width: double.infinity,
                    height: 220,
                    onTap: () => _openDetail(item),
                  );
                },
              ),
      ),
    );
  }
}
