import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import '../models/watch_progress.dart';
import '../services/catalog_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_row.dart';
import '../widgets/continue_watching_row.dart';
import '../widgets/hero_banner.dart';
import 'detail_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final CatalogService catalogService;
  final StorageService storageService;

  const HomeScreen({
    super.key,
    required this.catalogService,
    required this.storageService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFeaturedFavorite = false;

  @override
  void initState() {
    super.initState();
    widget.catalogService.addListener(_onCatalogUpdate);
    _checkFeaturedFavorite();
  }

  @override
  void dispose() {
    widget.catalogService.removeListener(_onCatalogUpdate);
    super.dispose();
  }

  void _onCatalogUpdate() {
    if (mounted) {
      _checkFeaturedFavorite();
      setState(() {});
    }
  }

  Future<void> _checkFeaturedFavorite() async {
    final featured = widget.catalogService.featuredItem;
    if (featured != null) {
      final isFav = await widget.storageService.isFavorite(featured.id);
      if (mounted) {
        setState(() {
          _isFeaturedFavorite = isFav;
        });
      }
    }
  }

  void _openDetail(MediaItem item) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => DetailScreen(
          item: item,
          storageService: widget.storageService,
        ),
      ),
    ).then((_) {
      _checkFeaturedFavorite();
      setState(() {});
    });
  }

  void _playMedia(MediaItem item) {
    final progress = widget.storageService.getProgress(item.id);
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PlayerScreen(
          item: item,
          initialPositionSeconds: progress?.positionSeconds,
          storageService: widget.storageService,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  List<({MediaItem item, WatchProgress progress})> _getContinueWatchingItems() {
    final allProgress = widget.storageService.getAllWatchProgress();
    final result = <({MediaItem item, WatchProgress progress})>[];

    for (final p in allProgress) {
      final item = widget.catalogService.getById(p.mediaId);
      if (item != null && p.progressFraction < 0.95) {
        result.add((item: item, progress: p));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final featured = widget.catalogService.featuredItem;
    final categories = widget.catalogService.categories;
    final continueList = _getContinueWatchingItems();

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // iOS Pull-to-refresh
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await widget.catalogService.syncRemote();
              _checkFeaturedFavorite();
            },
          ),

          // Empty State
          if (widget.catalogService.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                        child: const Icon(
                          CupertinoIcons.film,
                          size: 48,
                          color: AppTheme.accentGlow,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tu catálogo está listo',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Agrega tus películas y series desde tu PC usando el script agregar_contenido.ps1 o directamente desde la pestaña Ajustes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CupertinoButton(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(20),
                        onPressed: () async {
                          await widget.catalogService.syncRemote();
                          setState(() {});
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.arrow_2_circlepath, size: 16, color: CupertinoColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Sincronizar Catálogo',
                              style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            // Main Header / Hero
            if (featured != null)
              SliverToBoxAdapter(
                child: HeroBanner(
                  item: featured,
                  isFavorite: _isFeaturedFavorite,
                  onPlay: () => _playMedia(featured),
                  onToggleFavorite: () async {
                    await widget.storageService.toggleFavorite(featured.id);
                    _checkFeaturedFavorite();
                  },
                  onInfo: () => _openDetail(featured),
                ),
              ),

            // Continue Watching Row
            if (continueList.isNotEmpty)
              SliverToBoxAdapter(
                child: ContinueWatchingRow(
                  list: continueList,
                  onResume: (item, progress) => _playMedia(item),
                ),
              ),

            // Categories Rows
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Top Tendencias
                  CategoryRow(
                    title: 'Tendencias Ahora',
                    items: widget.catalogService.getByCategory('Tendencias'),
                    onItemTap: _openDetail,
                  ),
                  // Películas
                  CategoryRow(
                    title: 'Películas',
                    items: widget.catalogService.movies,
                    onItemTap: _openDetail,
                  ),
                  // Series
                  CategoryRow(
                    title: 'Series y Temporadas',
                    items: widget.catalogService.series,
                    onItemTap: _openDetail,
                  ),
                  // Other custom categories
                  for (final cat in categories)
                    if (!['tendencias', 'películas', 'peliculas', 'series']
                        .contains(cat.toLowerCase()))
                      CategoryRow(
                        title: cat,
                        items: widget.catalogService.getByCategory(cat),
                        onItemTap: _openDetail,
                      ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
