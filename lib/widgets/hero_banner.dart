import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class HeroBanner extends StatelessWidget {
  final MediaItem item;
  final bool isFavorite;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavorite;
  final VoidCallback onInfo;

  const HeroBanner({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onPlay,
    required this.onToggleFavorite,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = (screenHeight * 0.58).clamp(380.0, 520.0);

    return GestureDetector(
      onTap: onInfo,
      child: Stack(
        children: [
          // Banner Image
          SizedBox(
            height: bannerHeight,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: item.bannerUrl.isNotEmpty ? item.bannerUrl : item.posterUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.surfaceElevated,
                child: const Center(
                  child: CupertinoActivityIndicator(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceElevated,
                child: const Center(
                  child: Icon(
                    CupertinoIcons.film,
                    size: 64,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),

          // Gradient Overlay Top (for status bar readability)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),

          // Gradient Overlay Bottom (deep black fade into content)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x66000000),
                    Color(0xCC000000),
                    Color(0xFF000000),
                  ],
                  stops: [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // Content Box at Bottom
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.isSeries ? 'SERIE DESTACADA' : 'TOP DESTACADO',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.year}  •  ${item.genre}  •  ★ ${item.rating}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play Button
                    GestureDetector(
                      onTap: onPlay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40FFFFFF),
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.play_arrow_solid,
                              color: CupertinoColors.black,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Reproducir',
                              style: TextStyle(
                                color: CupertinoColors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // My List Button
                    GestureDetector(
                      onTap: onToggleFavorite,
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        opacity: 0.35,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFavorite
                                  ? CupertinoIcons.check_mark
                                  : CupertinoIcons.add,
                              color: isFavorite
                                  ? AppTheme.accentGlow
                                  : CupertinoColors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mi Lista',
                              style: TextStyle(
                                color: isFavorite
                                    ? AppTheme.accentGlow
                                    : CupertinoColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info Button
                    GestureDetector(
                      onTap: onInfo,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: BorderRadius.circular(22),
                        opacity: 0.35,
                        child: const Icon(
                          CupertinoIcons.info,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
