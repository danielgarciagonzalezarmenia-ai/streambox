import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/main_navigation_screen.dart';
import 'services/catalog_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark immersive cinema feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0D14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize storage & catalog
  final storageService = await StorageService.init();
  final catalogService = CatalogService(storageService: storageService);
  await catalogService.initialize();

  runApp(
    StreamBoxApp(
      storageService: storageService,
      catalogService: catalogService,
    ),
  );
}

class StreamBoxApp extends StatelessWidget {
  final StorageService storageService;
  final CatalogService catalogService;

  const StreamBoxApp({
    super.key,
    required this.storageService,
    required this.catalogService,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'StreamBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoDarkTheme,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
        Locale('en', ''),
      ],
      locale: const Locale('es', ''),
      home: MainNavigationScreen(
        catalogService: catalogService,
        storageService: storageService,
      ),
    );
  }
}
