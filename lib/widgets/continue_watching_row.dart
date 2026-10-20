import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import '../models/watch_progress.dart';
import '../theme/app_theme.dart';

class ContinueWatchingRow extends StatelessWidget {
  final List<({MediaItem item, WatchProgress progress})> list;
  final void Function(MediaItem item, WatchProgress progress) onResume;

  const ContinueWatchingRow({
    super.key,
    required this.list,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Continuar viendo',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final entry = list[index];
              final item = entry.item;
              final progress = entry.progress;

              return GestureDetector(
                onTap: () => onResume(item, progress),
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Backdrop / Poster with play overlay
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: Container(
                              height: 115,
                              width: 200,
                              color: AppTheme.surfaceElevated,
                              child: CachedNetworkImage(
                                imageUrl: item.bannerUrl.isNotEmpty
                                    ? item.bannerUrl
                                    : item.posterUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    Container(color: AppTheme.surfaceElevated),
                              ),
                            ),
                          ),
                          // Dark tint
                          Positioned.fill(
                            child: Container(
                              color: const Color(0x33000000),
                            ),
                          ),
                          // Play Icon in Center
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0x99000000),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.play_arrow_solid,
                                  color: CupertinoColors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(2),
                        ),
                        child: Container(
                          height: 3,
                          width: 200,
                          color: const Color(0xFF333333),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 200 * progress.progressFraction,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.isSeries && progress.episodeNumber != null
                            ? 'T${progress.seasonNumber ?? 1} : E${progress.episodeNumber}'
                            : item.genre,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
