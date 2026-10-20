import 'package:flutter/cupertino.dart';
import '../models/episode.dart';
import '../models/media_item.dart';
import '../models/season.dart';
import '../services/catalog_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  final CatalogService catalogService;
  final StorageService storageService;

  const SettingsScreen({
    super.key,
    required this.catalogService,
    required this.storageService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;
  String? _syncMessage;

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    final ok = await widget.catalogService.syncRemote();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncMessage = ok
            ? '¡Catálogo sincronizado con éxito!'
            : (widget.catalogService.lastError ?? 'Error de conexión');
      });
    }
  }

  void _showChangeUrlDialog() {
    final controller =
        TextEditingController(text: widget.storageService.getCatalogUrl());

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('URL del Catálogo Remoto'),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                const Text(
                  'Introduce la URL directa (raw) a tu archivo catalog.json:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: controller,
                  placeholder: 'https://.../catalog.json',
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Guardar y Sincronizar'),
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isNotEmpty) {
                  await widget.storageService.setCatalogUrl(url);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _handleSync();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddMediaModal() {
    final titleCtrl = TextEditingController();
    final posterCtrl = TextEditingController();
    final bannerCtrl = TextEditingController();
    final videoCtrl = TextEditingController();
    final genreCtrl = TextEditingController(text: 'Acción');
    final yearCtrl = TextEditingController(text: '2025');
    final durationCtrl = TextEditingController(text: '1h 45m');
    final descCtrl = TextEditingController();
    String mediaType = 'movie'; // 'movie' or 'series'
    final episodes = <Episode>[];

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF141824),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar Título Local',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.xmark_circle_fill),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selector Película / Serie
                    CupertinoSegmentedControl<String>(
                      borderColor: AppTheme.accent,
                      selectedColor: AppTheme.accent,
                      unselectedColor: AppTheme.surface,
                      groupValue: mediaType,
                      onValueChanged: (val) {
                        setModalState(() {
                          mediaType = val;
                        });
                      },
                      children: const {
                        'movie': Padding(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Text('Película', style: TextStyle(color: CupertinoColors.white)),
                        ),
                        'series': Padding(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Text('Serie', style: TextStyle(color: CupertinoColors.white)),
                        ),
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFormField('Título', titleCtrl, 'Ej. Gladiator II'),
                    _buildFormField('URL del Póster (Vertical)', posterCtrl, 'https://.../poster.jpg'),
                    _buildFormField('URL del Banner (Horizontal)', bannerCtrl, 'https://.../banner.jpg'),
                    _buildFormField('Género', genreCtrl, 'Ej. Acción, Ciencia Ficción'),
                    Row(
                      children: [
                        Expanded(child: _buildFormField('Año', yearCtrl, '2025')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildFormField('Duración', durationCtrl, '1h 50m')),
                      ],
                    ),
                    _buildFormField('Sinopsis / Descripción', descCtrl, 'Resumen...', maxLines: 2),

                    if (mediaType == 'movie') ...[
                      _buildFormField(
                        'URL del Video (MP4 / M3U8)',
                        videoCtrl,
                        'https://.../pelicula.mp4',
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Episodios de la Serie',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Row(
                              children: [
                                Icon(CupertinoIcons.plus_circle, size: 16),
                                SizedBox(width: 4),
                                Text('Agregar Ep.', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            onPressed: () {
                              _showAddEpisodeDialog(
                                context,
                                episodes.length + 1,
                                (newEp) {
                                  setModalState(() {
                                    episodes.add(newEp);
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      for (final ep in episodes)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'E${ep.episodeNumber}: ${ep.title}',
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                ep.duration,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],

                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      child: const Text('Guardar en la App'),
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;

                        final newItem = MediaItem(
                          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          type: mediaType,
                          genre: genreCtrl.text.trim(),
                          year: yearCtrl.text.trim(),
                          duration: durationCtrl.text.trim(),
                          rating: '5.0',
                          description: descCtrl.text.trim(),
                          posterUrl: posterCtrl.text.trim(),
                          bannerUrl: bannerCtrl.text.trim(),
                          videoUrl: mediaType == 'movie' ? videoCtrl.text.trim() : null,
                          categories: ['Recientes', genreCtrl.text.trim()],
                          seasons: mediaType == 'series'
                              ? [
                                  Season(
                                    seasonNumber: 1,
                                    title: 'Temporada 1',
                                    episodes: episodes,
                                  )
                                ]
                              : [],
                        );

                        await widget.catalogService.addLocalMediaItem(newItem);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEpisodeDialog(
    BuildContext ctx,
    int nextNumber,
    void Function(Episode) onAdd,
  ) {
    final epTitleCtrl = TextEditingController(text: 'Episodio $nextNumber');
    final epUrlCtrl = TextEditingController();
    final epDurCtrl = TextEditingController(text: '45m');

    showCupertinoDialog(
      context: ctx,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Nuevo Episodio $nextNumber'),
          content: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: epTitleCtrl,
                placeholder: 'Título del episodio',
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: epUrlCtrl,
                placeholder: 'URL de video (MP4 / M3U8)',
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: epDurCtrl,
                placeholder: 'Duración (ej. 45m)',
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Agregar'),
              onPressed: () {
                if (epUrlCtrl.text.trim().isNotEmpty) {
                  onAdd(
                    Episode(
                      episodeNumber: nextNumber,
                      title: epTitleCtrl.text.trim(),
                      videoUrl: epUrlCtrl.text.trim(),
                      duration: epDurCtrl.text.trim(),
                      description: '',
                      posterUrl: '',
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String placeholder, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            maxLines: maxLines,
            placeholderStyle: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
            ),
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 13,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.divider),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = widget.storageService.getCatalogUrl();
    final lastSync = widget.catalogService.lastSyncTime;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Sincronización y Ajustes',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: Color(0xCC000000),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sync status card
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.catalogService.lastError == null
                              ? const Color(0xFF30D158) // iOS green
                              : const Color(0xFFFF453A), // iOS red
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Estado de Sincronización',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'URL Activa:\n$currentUrl',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Courier',
                    ),
                  ),
                  if (lastSync != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Última sync: ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}:${lastSync.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (_syncMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _syncMessage!,
                      style: TextStyle(
                        color: widget.catalogService.lastError == null
                            ? const Color(0xFF30D158)
                            : const Color(0xFFFF453A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          color: AppTheme.accent,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: _isSyncing ? null : _handleSync,
                          child: _isSyncing
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.arrow_2_circlepath,
                                      size: 16,
                                      color: CupertinoColors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Sincronizar Ahora',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton(
                        color: AppTheme.surfaceElevated,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        onPressed: _showChangeUrlDialog,
                        child: const Icon(
                          CupertinoIcons.link,
                          size: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Add local title button
            CupertinoButton(
              color: AppTheme.surfaceElevated,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              onPressed: _showAddMediaModal,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.plus_app,
                    color: AppTheme.accentGlow,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Agregar Película o Serie desde el iPhone',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Instructions Guide Box
            const Text(
              '¿CÓMO AGREGAR CONTENIDO DESDE TU PC?',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Abre el archivo catalog.json en tu PC.',
                    style: TextStyle(color: CupertinoColors.white, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '2. Agrega el nuevo objeto con el título, URL del video y del póster (o corre el script agregar_contenido.ps1).',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '3. Sube el cambio con `git push`.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '4. Al abrir StreamBox en tu iPhone (o deslizar hacia abajo en Inicio), el contenido aparecerá automáticamente.',
                    style: TextStyle(
                      color: Color(0xFF64D2FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // About
            Center(
              child: Column(
                children: [
                  const Text(
                    'StreamBox iOS • Edición Cine',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versión 1.0.0 (Build 1) • Diseñado para iPhone',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
