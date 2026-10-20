import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import '../services/catalog_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final CatalogService catalogService;
  final StorageService storageService;

  const SearchScreen({
    super.key,
    required this.catalogService,
    required this.storageService,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'all'; // 'all', 'movie', 'series'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(MediaItem item) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => DetailScreen(
          item: item,
          storageService: widget.storageService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final results = widget.catalogService.search(
      query,
      typeFilter: _selectedType == 'all' ? null : _selectedType,
    );

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Explorar',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: Color(0xCC000000),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Buscar títulos, actores o géneros...',
                style: const TextStyle(color: CupertinoColors.white),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // Type filter segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl<String>(
                  borderColor: AppTheme.divider,
                  selectedColor: AppTheme.accent,
                  unselectedColor: AppTheme.surface,
                  pressedColor: AppTheme.surfaceElevated,
                  groupValue: _selectedType,
                  onValueChanged: (val) {
                    setState(() {
                      _selectedType = val;
                    });
                  },
                  children: const {
                    'all': Padding(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Text(
                        'Todos',
                        style: TextStyle(fontSize: 13, color: CupertinoColors.white),
                      ),
                    ),
                    'movie': Padding(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Text(
                        'Películas',
                        style: TextStyle(fontSize: 13, color: CupertinoColors.white),
                      ),
                    ),
                    'series': Padding(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Text(
                        'Series',
                        style: TextStyle(fontSize: 13, color: CupertinoColors.white),
                      ),
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Grid of items
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.search,
                            size: 48,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            query.isEmpty
                                ? 'No hay títulos disponibles'
                                : 'No se encontraron resultados para "$query"',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return MediaCard(
                          item: item,
                          width: double.infinity,
                          height: 220,
                          onTap: () => _openDetail(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
