import 'package:flutter/cupertino.dart';
import '../services/catalog_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'my_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final CatalogService catalogService;
  final StorageService storageService;

  const MainNavigationScreen({
    super.key,
    required this.catalogService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xE60A0D14),
        activeColor: AppTheme.accent,
        inactiveColor: AppTheme.textMuted,
        iconSize: 22,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            activeIcon: Icon(CupertinoIcons.search),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bookmark),
            activeIcon: Icon(CupertinoIcons.bookmark_fill),
            label: 'Mi Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt),
            activeIcon: Icon(CupertinoIcons.gear_alt_fill),
            label: 'Ajustes',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return HomeScreen(
              catalogService: catalogService,
              storageService: storageService,
            );
          case 1:
            return SearchScreen(
              catalogService: catalogService,
              storageService: storageService,
            );
          case 2:
            return MyListScreen(
              catalogService: catalogService,
              storageService: storageService,
            );
          case 3:
            return SettingsScreen(
              catalogService: catalogService,
              storageService: storageService,
            );
          default:
            return HomeScreen(
              catalogService: catalogService,
              storageService: storageService,
            );
        }
      },
    );
  }
}
