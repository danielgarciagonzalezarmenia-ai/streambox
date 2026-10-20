import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool showTitle;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: width,
                    height: height,
                    color: AppTheme.surfaceElevated,
                    child: CachedNetworkImage(
                      imageUrl: item.posterUrl,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.film,
                              color: AppTheme.textMuted,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Type badge (Serie / Película)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      item.isSeries ? 'SERIE' : 'PELÍCULA',
                      style: TextStyle(
                        color: item.isSeries
                            ? const Color(0xFF64D2FF)
                            : AppTheme.accentGlow,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                if (item.rating.isNotEmpty)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xDD000000),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.star_fill,
                            color: Color(0xFFFFD60A),
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.rating,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (showTitle) ...[
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.year} • ${item.genre}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
